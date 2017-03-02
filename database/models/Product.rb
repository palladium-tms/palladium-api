class Product < Sequel::Model
  one_to_many :plans
  plugin :validation_helpers
  self.raise_on_save_failure = false
  self.plugin :timestamps

  def validate
    validates_unique :name
    validates_format /^.{1,30}$/, :name
  end

  def self.product_id_validation(product_id)
    case
      when product_id.nil?
        return {'product_id': ["product_id can't be nil"]}
      when product_id.empty?
        return {'product_id': ["product_id can't be empty"]}
      when Product[id: product_id].nil?
        return {'product_id': ["product_id is not belongs to any product"]}
    end
    {}
  end

  def before_destroy
    super
    self.remove_all_plans
  end

  def self.create_new(data)
    product = self.new(data)
    product.save
    product
  end
end