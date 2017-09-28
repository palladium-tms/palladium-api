class Product < Sequel::Model
  one_to_many :plans
  one_to_many :suites
  plugin :validation_helpers
  plugin :timestamps, :force => true, :update_on_create => true, :create => :created_at


  def before_destroy
    super
    Plan.where(product_id: self.id).each do |plan|
      plan.destroy
    end
    Suite.where(product_id: self.id).each do |suite|
      suite.destroy
    end
  end

  def validate
    super
    validates_unique :name
    validates_presence :name
  end

  def self.product_id_validation(product_id)
    case
      when product_id.nil?
        return {'product_id' => ["product_id can't be nil"]}
      when product_id.empty?
        return {'product_id' => ["product_id can't be empty"]}
      when Product[id: product_id].nil?
        return {'product_id' => ['product_id is not belongs to any product']}
    end
    {}
  end

  # @param [Hash] data must be like {:product_data => {name: 'product_name'}}
  # @return [ProductObject]
  def self.create_new(data)
    err_product = nil
    product_name = data['product_data']['name']
    if product_name.nil? || product_name == ''
      Product.new(name: product_name)
    else
      Product.find_or_create(:name => product_name) {|product|
        product.name = data['product_data']['name']
      }
    end
  end

  def self.edit(product_id, product_name)
    product = Product[:id => product_id]
    product.update(:name => product_name, :updated_at => Time.now)
    product.valid?
    {'product_data': product.values, 'errors': product.errors}.to_json
  end

  def self.get_plans(*args)
    product = if args.first['product_id']
                Product[:id => args.first['product_id']]
              elsif args.first['product_name']
                Product[:name => args.first['product_name']]
              end
    begin
      [product.plans, []]
    rescue StandardError
      [[], 'Plan data is incorrect']
    end
  end

  def self.get_statistic(plans)
    ResultSet.where(:plan_id => plans.map(&:id)).group_and_count(:plan_id, :status).map(&:values).group_by do |e|
      e[:plan_id]
    end
  end

  def self.add_statictic(plans)
    statistic = get_statistic(plans)
    plans.map(&:values).map do |plan|
      plan.merge!({statistic: statistic[plan[:id]] || []})
    end
  end

  def self.add_case_counts(suites)
    statistic = get_cases_count(suites)
    suites.map(&:values).map do |suite|
       if statistic.has_key?(suite[:id])
         suite.merge!({statistic: [statistic[suite[:id]].first.merge!({status: 0})]})
       else
         suite.merge!({statistic: [{status: 0, count: 0, suite_id: suite[:id]}]})
       end
    end
  end

  def self.get_cases_count(suites)
     Case.where(:suite_id => suites.map(&:id)).group_and_count(:suite_id).map(&:values).group_by do |e|
       e[:suite_id]
     end
  end
end