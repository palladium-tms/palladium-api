class Case < Sequel::Model
  many_to_one :suite
  plugin :validation_helpers
  plugin :association_dependencies
  self.raise_on_save_failure = false
  plugin :timestamps

  def before_destroy
    plan_ids = suite.product.plans.map(&:id)
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
end
