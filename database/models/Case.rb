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
      if Suite[name: Run[case_data['run_id']].name, product_id: case_data['product_id']]
        Suite[name: Run[case_data['run_id']].name, product_id: case_data['product_id']].cases
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
end
