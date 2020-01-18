# frozen_string_literal: true

class Case < Sequel::Model
  many_to_one :suite
  plugin :validation_helpers
  self.raise_on_save_failure = false
  plugin :timestamps, force: true, update_on_create: true

  def before_destroy
    plan_ids = [*Plan[product_id: suite.product.id, is_archived: false]].map(&:id)
    runs_id = Run.where(name: suite.name, plan_id: plan_ids).map(&:id)
    ResultSet.where(name: name, plan_id: plan_ids, run_id: runs_id).each do |current_result_set|
      current_result_set.remove_all_results
      current_result_set.destroy
    end
  end

  def self.get_cases(case_data = {})
    if case_data['suite_id']
      Suite[case_data['suite_id']].cases
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

  # return result_sets for all plans
  # example: {id => result_set, ...}
  def self.get_history(params)
    records_limit = 30
    offset = params['offset']
    offset = 0 if params['offset'].nil?
    suite = get_suite(params['case_data'])
    plans = get_plans(suite.product.id, records_limit, offset)
    runs = get_runs(plans.map(&:id), suite)
    name = get_name(params['case_data'])
    result_sets = get_result_sets(plans.map(&:id), runs.map(&:id), name)
    result_sets = result_sets.map do |result_set|
      result_set['plan'] = plans.find { |plan| plan.id == result_set[:plan_id] }.values
      result_set
    end
    result_sets
  end

  def self.get_suite(case_data)
    if case_data['id']
      Case[case_data['id']].suite
    else
      run = ResultSet[case_data['result_set_id']].run
      run.plan.product.suites.find { |suite| suite.name == run.name}
    end
  end

  def self.get_name(case_data)
    if case_data['id']
      Case[case_data['id']].name
    else
      ResultSet[case_data['result_set_id']].name
    end
  end

  def self.get_plans(product_id, records_limit, offset)
    Plan.dataset.where(product_id: product_id).order(Sequel.desc(:updated_at)).limit(records_limit, offset).all
  end

  def self.get_runs(plan_ids, suite)
    Run.dataset.where(plan_id: plan_ids, name: suite.name)
  end

  def self.get_result_sets(plan_ids, runs, name)
    ResultSet.dataset.where(plan_id: plan_ids, run_id: runs, name: name).map(&:values)
  end
end
