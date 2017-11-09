class Case < Sequel::Model
  many_to_one :suite
  plugin :validation_helpers
  plugin :association_dependencies
  self.raise_on_save_failure = false
  plugin :timestamps

  def before_destroy
    plan_ids = self.suite.product.plans.map(&:id)
    ResultSet.where(name: name, plan_id: plan_ids).each do |current_result_set|
      current_result_set.remove_all_results
      current_result_set.destroy
    end
  end

  def self.get_cases(case_data = {})
    if case_data['suite_id']
      Case.where(suite_id: case_data['suite_id'])
    elsif case_data['run_id']
      run = Run[case_data['run_id']]
      if Suite[name: run.name, product_id: run.plan.product.id]
        Suite[name: run.name, product_id: run.plan.product.id].cases
      else
        []
      end
    end
  end

  def self.edit(case_data)
    if case_data['id']
      this_case = Case[case_data['id']]
      suite = this_case.suite
      plan_ids = suite.product.plans.map(&:id)
      run_ids = Run.where(plan_id: plan_ids, name: suite.name).map(&:id)
      ResultSet.where(name: this_case.name, run_id: run_ids).each do |current_result_set|
        current_result_set.update(name: case_data['name'])
      end
      this_case.update(name: case_data['name'])
    else
      result_set = ResultSet[case_data['result_set_id']]
      product = result_set.run.plan.product
      plan_ids = product.plans.map(&:id)
      run_ids = Run.where(plan_id: plan_ids, name: result_set.run.name).map(&:id)
      suite_id = Suite[name: result_set.run.name, product_id: product.id].id
      this_case = Case[suite_id: suite_id, name: result_set.name]
      ResultSet.where(name: result_set.name, run_id: run_ids).each do |current_result_set|
        current_result_set.update(name: case_data['name'])
      end
      this_case.update(name: case_data['name'])
    end
  end

  def self.get_history(params)
    records_limit = 30
    offset = params['offset']
    offset = 0 if params['offset'].nil?
    suite = Case[params['case_data']['id']].suite
    plans = Plan.dataset.where(product_id: suite.product.id).select(:id, :name, ).limit(records_limit, offset).all
    plan_ids = plans.map(&:id)
    result = plans.map! {|e| {plan_id: e.values[:id], plan_name: e.values[:name]}}
    runs = Run.dataset.where(plan_id: plan_ids, name: suite.name)
    grouped_runs = runs.all.group_by do |e|
      (e.plan || plans).id
    end
    result.each {|e| e[:run] = {run_id: grouped_runs[e[:plan_id]].first.values[:id]}}
    result_sets = ResultSet.dataset.where(plan_id: plan_ids, run_id: runs.map(&:id))
    grouped_result_set = result_sets.all.group_by do |e|
      (e.run || runs.all).id
    end
    result.each {|e|
      e[:run][:result_set] = {
          result_set_id: grouped_result_set[e[:run][:run_id]].first.values[:id],
          result_set_updated_at: grouped_result_set[e[:run][:run_id]].first.values[:updated_at],
          status: grouped_result_set[e[:run][:run_id]].first.values[:status]}
    }
    results = Result.dataset.where(result_sets: result_sets).all.group_by do |e|
      (e.result_sets || result_sets.all).first.id
    end
    results.transform_values! do |results|
      {statistic: results.group_by(&:status_id).transform_values!(&:size), results: Hash[results.map {|result| [result.id, result.status_id]}]}
    end
    result.each {|e|
      e[:run][:result_set].merge!(results[e[:run][:result_set][:result_set_id]])
    }
    result
  end
end
