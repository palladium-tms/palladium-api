class Product < Sequel::Model
  plugin :validation_helpers
  self.raise_on_save_failure = false
  self.plugin :timestamps

  def validate
    validates_unique :name
    validates_format /^.{1,30}$/, :name
  end

  def self.create_new(data)
      product = self.new(data)
      product.save
      product
  end
end