class Case < Sequel::Model
  many_to_one :suite
  plugin :validation_helpers
  plugin :association_dependencies
  self.raise_on_save_failure = false
  plugin :timestamps

  def before_destroy
    plan_ids = self.suite.product.plans.map(&:id)
    runs_id = Run.where(name: self.suite.name, plan_id: plan_ids).map(&:id)
    ResultSet.where(name: name, plan_id: plan_ids, run_id: runs_id).each do |current_result_set|
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
    # Algorithm:
    # 1) Get suite and plans by case_id
    # 2) Get runs with plan_ids and Suite.name
    # 3) Group runs: {plan_id: runs, plan_id: runs}
    # 4) Get results_sets with name == case.name, plan_id == one of plan_ids and run_id == one of run_ids
    # 5)
    records_limit = 30
    offset = params['offset']
    offset = 0 if params['offset'].nil?
    suite = get_suite(params['case_data']['id'])
    plans, plan_ids = get_plans(suite.product.id, records_limit, offset)
    result = plans.map! { |e| { plan_id: e.values[:id], plan_name: e.values[:name],
                              updated_at: e.values[:created_at] } }
    runs, grouped_runs = get_runs(plan_ids, suite)
    result.each { |e|
      if grouped_runs[e[:plan_id]]
        e[:run_id] = grouped_runs[e[:plan_id]].first.values[:id]
      else
        e.merge!({suite_id: suite.id})
      end
      e.merge!({status: 0})
    }
    result_sets, grouped_result_set = get_result_sets(plan_ids, runs, params['case_data']['id'])
    result.each { |e|
      unless e[:suite_id]
        if grouped_result_set[e[:run_id]]
          e.merge!({result_set_id: grouped_result_set[e[:run_id]].first.values[:id]})
          e.merge!({updated_at: grouped_result_set[e[:run_id]].first.values[:updated_at]})
          e.merge!({ status: grouped_result_set[e[:run_id]].first.values[:status]})
        end
      end
    }
    results = {}
    result_sets.all.each do |result_set|
      results.merge!({result_set.id => result_set.results})
    end
    results.transform_values! do |results|
      { statistic: results.group_by(&:status_id).transform_values!(&:size),
        results: Hash[results.map { |result| [result.id, result.status_id] } ] }
    end
    result.each do |e|
      unless e[:suite_id]
        if e[:result_set_id] && !results.empty?
          e.merge!(results[e[:result_set_id]])
        end
      end
    end
    result
  end

  def self.get_suite(case_id)
    Case[case_id].suite
  end

  def self.get_plans(product_id, records_limit, offset)
    plans = Plan.dataset.where(product_id: product_id).select(:id, :name, :created_at).limit(records_limit, offset).all
    [plans, plans.map(&:id)]
  end

  def self.get_runs(plan_ids, suite)
    runs = Run.dataset.where(plan_id: plan_ids, name: suite.name)
    grouped_runs = runs.all.group_by do |e|
      (e.plan || plans).id
    end
    [runs, grouped_runs]
  end

  def self.get_result_sets(plan_ids, runs, this_case)
    result_sets = ResultSet.dataset.where(plan_id: plan_ids, run_id: runs.map(&:id), name: Case[this_case].name)
    grouped_result_set = result_sets.all.group_by do |e|
      (e.run || runs.all).id
    end
    [result_sets, grouped_result_set]
  end
end
