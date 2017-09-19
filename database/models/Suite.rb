class Suite < Sequel::Model
  many_to_one :product
  one_to_many :cases
  plugin :validation_helpers
  plugin :association_dependencies
  add_association_dependencies cases: :destroy
  self.raise_on_save_failure = false
  plugin :timestamps
end
