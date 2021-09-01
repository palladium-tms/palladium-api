# frozen_string_literal: true

class Plan < Sequel::Model
  many_to_one :product
  one_to_many :runs
  many_to_many :suites
  one_to_many :result_sets
  many_to_many :cases
  plugin :validation_helpers
  plugin :association_dependencies
  add_association_dependencies runs: :destroy
  add_association_dependencies suites: :nullify
  add_association_dependencies cases: :nullify
  self.raise_on_save_failure = false
  plugin :timestamps

  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
  end

  def self.product_id_validation(plan, product_id)
    if product_id.nil?
      plan.errors.add('product_id', "product_id can't be nil")
      return plan
    elsif Product[id: product_id].nil?
      plan.errors.add('product_id', 'product_id is not belongs to any product')
      return plan
    end
    plan
  end

  def self.plan_id_validation(plan_id)
    if plan_id.nil?
      return { 'plan_id' => ["plan_id can't be nil"] }
    elsif Plan[id: plan_id].nil?
      return { 'plan_id' => ['plan_id is not belongs to any product'] }
    end

    []
  end

  def self.getting_product(data)
    if data['plan_data']['product_id'].nil?
      new_product = Product.new(name: data['plan_data']['product_name'])
      new_product.valid?
      if new_product.valid?
        Product.find_or_create(name: data['plan_data']['product_name'])
      else
        new_product
      end
    else
      Product[id: data['plan_data']['product_id']]
    end
  end

  def self.find_or_new(data, product_id)
    Plan.find(name: data, product_id: product_id) || Plan.new(name: data)
  end

  # @param [Hash] data
  # example: data = {'plan_data': {'product_id': id, 'name': name}} or {'plan_data': {'product_name': name, 'name': name}}
  # return responce = {product: {product_data}, plan: {plan_data}, errors:: {product_errors: {}, plan_errors: {}}}
  def self.create_new(data)
    return { plan: Plan[id: data['run_data']['plan_id']] } if plan_id_exist?(data)

    product_resp = create_product(data)
    if product_resp[:product].nil?
      { plan_errors: 'product creating error' }.merge(product_resp)
    else
      api_created = data['plan_data']['api_created']
      api_created = true if api_created.nil?
      existed_plan = Plan.find(name: data['plan_data']['name'], product_id: product_resp[:product].id)
      return { plan: existed_plan, request_status: 'Plan with this name is exist', product: product_resp[:product] } if existed_plan

      new_plan = Plan.new(name: data['plan_data']['name'], api_created: api_created)
      if new_plan.valid?
        new_plan.save_changes
        product_resp[:product].add_plan(new_plan)
        associate_for_plan(new_plan, product_resp[:product]) if new_plan.suites.empty? && api_created
        { plan: new_plan }.merge(product_resp)
      else
        { plan_errors: new_plan.errors.full_messages }
      end
    end
  end

  def self.associate_for_plan(plan, product)
    suites = product.suites.select { |suite| !suite[:deleted] }
    suites.each do |suite|
      plan.add_suite(suite)
    end
    suites_id = suites.map(&:id)
    Case.where(suite_id: suites_id, deleted: false).all.each do |current_case|
      plan.add_case(current_case)
    end
  end

  def self.create_product(data)
    unless data['plan_data'].nil?
      return Product.create_new(data['plan_data']['product_id'] || data['plan_data']['product_name']) unless data['plan_data']['product_id'].nil? && data['plan_data']['product_name'].nil?
    end
    { product_errors: 'product id of name not found' }
  end

  def self.plan_id_exist?(data)
    return !data['run_data']['plan_id'].nil? unless data['run_data'].nil?

    false
  end

  # @param data [Hash] like {'plan_data' => {id: int, plan_name: str}}
  def self.edit(data)
    plan = Plan[id: data['plan_data']['id']]
    if plan.set(name: data['plan_data']['plan_name']).valid?
      if Plan[name: data['plan_data']['plan_name'], product_id: plan.product_id].nil?
        plan.update(name: data['plan_data']['plan_name'], updated_at: Time.now)
        plan
      else
        { plan_errors: ['plan name already used'] }
      end
    else
      { plan_errors: plan.errors.full_messages }
    end
  end

  def self.get_runs(plan_id)
    plan = Plan[id: plan_id]
    suites = if plan.suites.empty?
               plan.product.suites
             else
               plan.suites
             end
    suites = Product.add_case_counts(suites, plan)
    begin
      [{ runs: plan.runs, plan: plan.values }, suites, []]
    rescue StandardError
      [[], [], 'Run data is incorrect']
    end
  end

  def self.get_statistic(runs)
    ResultSet.join(Run.where(id: runs.map(&:id)), id: :run_id).group_and_count(:run_id, :status).map(&:values).group_by do |e|
      e[:run_id]
    end
  end

  def self.add_statictic(runs)
    statistic = get_statistic(runs)
    runs.map(&:values).map do |run|
      run.merge!(statistic: statistic[run[:id]] || [])
    end
  end

  # Getting statistic and save in database(usually, statistic is not saving)
  # Creating result_set and run for all cases and suites, if it not be created before
  def self.archive(plan_id)
    a = Time.now
    plan = Plan[plan_id]
    runs = plan.runs
    suites = {}
    plan.product.suites.each do |suite|
      suites[suite.name] = suite
    end
    (suites.values.map(&:name) - runs.map(&:name)).each do |run_name|
      new_run = Run.find_or_new(run_name, plan.id)
      plan.add_run(new_run)
      runs << new_run
      suites[new_run.name].cases.each do |this_case|
        new_result_set = ResultSet.find_or_new(this_case.name, new_run.id)
        plan.add_result_set(new_result_set)
        new_run.add_result_set(new_result_set)
      end
    end
    runs_filling(runs, suites)
    statistic = Product.get_statistic(plan_id)[plan_id] || {}
    plan.update(statistic: statistic.to_json)
    plan.update(is_archived: true)
    p Time.now - a
    plan
  end

  def self.runs_filling(runs, suites)
    runs.each do |run|
      if run.result_sets.count != suites[run.name].cases.count
        (suites[run.name].cases.map(&:name) - run.result_sets.map(&:name)).each do |result_set_name|
          new_result_set = ResultSet.find_or_new(result_set_name, run.id)
          run.plan.add_result_set(new_result_set)
          run.add_result_set(new_result_set)
        end
      end
    end
  end

  def self.add_all_suites(plan)
    plan.product.suites.each do |current_suite|
      plan.add_suite(current_suite)
    end
    plan
  end

  def self.add_all_cases(plan)
    Case.where_all(suite_id: plan.product.suites.map(&:id)).each do |current_case|
      plan.add_case current_case
    end
    plan
  end

  def self.remove_cases_by_suite(plan, suite)
    suite.cases.each do |current_case|
      plan.remove_case(current_case)
    end
    plan
  end
end
