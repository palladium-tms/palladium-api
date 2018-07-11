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
      product.save
      { product: product }
    else
      { product_errors: product.errors.full_messages }
    end
  end

  def self.edit(product_id, product_name)
    product = Product[id: product_id]
    if product.set(name: product_name).valid?
      product.update(name: product_name, updated_at: Time.now)
      { product_data: product.values }.to_json
    else
      { product_errors: product.errors }.to_json
    end
  end

  def self.get_plans(*args)
    product = if args.first['product_id']
                Product[id: args.first['product_id']]
              elsif args.first['product_name']
                Product[name: args.first['product_name']]
              end
    begin
      [product.plans, []]
    rescue StandardError
      [[], 'Plan data is incorrect']
    end
  end

  def self.get_statistic(plans)
    ResultSet.where(plan_id: plans.map(&:id)).group_and_count(:plan_id, :status).map(&:values).group_by do |e|
      e[:plan_id]
    end
  end

  def self.add_statictic(plans)
    statistic = get_statistic(plans)
    plans.map(&:values).map do |plan|
      plan.merge!(statistic: statistic[plan[:id]] || [])
    end
  end

  def self.add_case_counts(suites)
    statistic = get_cases_count(suites)
    suites.map(&:values).map do |suite|
      if statistic.key?(suite[:id])
        suite.merge!(statistic: [statistic[suite[:id]].first.merge!(status: 0)])
      else
        suite.merge!(statistic: [{ status: 0, count: 0, suite_id: suite[:id] }])
      end
    end
  end

  def self.get_cases_count(suites)
    Case.where(suite_id: suites.map(&:id)).group_and_count(:suite_id).map(&:values).group_by do |e|
      e[:suite_id]
    end
  end
end
