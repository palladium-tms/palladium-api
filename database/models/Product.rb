# frozen_string_literal: true

class Product < Sequel::Model
  one_to_many :plans
  one_to_many :suites
  plugin :validation_helpers
  plugin :timestamps, force: true, update_on_create: true, create: :created_at
  plugin :association_dependencies
  add_association_dependencies plans: :destroy, suites: :destroy

  def validate
    super
    if name.nil?
      errors.add(:name, 'cannot be nil') if name.nil?
    else
      validates_unique :name
      errors.add(:name, 'cannot be empty') if name.empty?
      errors.add(:name, 'cannot contains only spaces') if name.strip.empty? & !name.empty?
    end
  end

  def self.product_id_validation(product_id)
    if product_id.nil?
      return { product_id: ["product_id can't be empty"] }
    elsif Product[id: product_id].nil?
      return { product_id: ['product_id is not belongs to any product'] }
    end

    {}
  end

  # try to find element by name of id(str or number), of create new product by str=name
  def self.find_or_new(data)
    return Product[id: data] if data.is_a?(Numeric)

    Product.find(name: data) || Product.new(name: data)
  end

  # @param [Hash] data must be like {:product_data => {name: 'product_name'}}
  # @return [ProductObject]
  def self.create_new(data)
    product = Product.find_or_new(data)
    if product.valid?
      product.save_changes
      { product: product }
    else
      { product_errors: product.errors.full_messages }
    end
  end

  def self.edit(product_id, product_name)
    product = Product[id: product_id]
    if product.set(name: product_name).valid?
      product.update(name: product_name, updated_at: Time.now)
      { product: product.values }.to_json
    else
      { product_errors: product.errors }.to_json
    end
  end

  def self.get_plans(option = {})
    limit = JSON.parse(File.read("config/palladium.json"))['count_of_plan_loading']
    request_status = ''
    product = if option['product_id']
                Product[id: option['product_id']]
              elsif option['product_name']
                Product[name: option['product_name']]
              end
    begin
      all_plans = Plan.where(product_id: product.id).order(Sequel.desc(:id))
      plans = if option['after_plan_id'] && option['after_plan_id'].is_a?(Numeric)
                all_plans.where(Sequel.lit('id < ?', option['after_plan_id'].to_i)).limit(limit).all
              elsif option['plan_id'] && option['plan_id'].is_a?(Numeric)
                all_plans.where(Sequel.lit('id >= ?', option['plan_id'])).all
              else
                all_plans.limit(limit).all
              end
      request_status = 'Is a last plans' if plans.size < limit || Plan.count < limit
      plan_object = []
      all_case_count = Case.where(suite_id: product.suites.map(&:id)).count
      plans.each do |plan|
        case_count = if plan.cases.empty?
                       all_case_count
                     else
                       plan.cases.size
                     end
        plan_object << plan.values.merge(case_count: case_count)
      end
      return { plans: plan_object, errors: [], request_status: request_status }
    rescue StandardError
      { plans: [], errors: ['Plan data is incorrect'], request_status: request_status }
    end
  end

  def self.get_statistic(plan_ids)
    ResultSet.where(plan_id: plan_ids).group_and_count(:plan_id, :status).map(&:values).group_by do |e|
      e[:plan_id]
    end
  end

  def self.add_case_counts(suites, plan)
    statistic = get_cases_count(suites, plan)
    suites.map(&:values).map do |suite|
      if statistic.key?(suite[:id])
        suite.merge!(statistic: [statistic[suite[:id]].first.merge!(status: 0)])
      else
        suite.merge!(statistic: [{ status: 0, count: 0, suite_id: suite[:id] }])
      end
    end
  end

  def self.get_cases_count(suites, plan)
    if !plan.cases.empty?
      case_ids = plan.cases.map(&:id)
      Case.where(id: case_ids)
          .where(suite_id: suites.map(&:id))
          .group_and_count(:suite_id).map(&:values).group_by do |e|
        e[:suite_id]
      end

    else
      Case.where(suite_id: suites.map(&:id)).group_and_count(:suite_id).map(&:values).group_by do |e|
        e[:suite_id]
      end
    end
  end
end
