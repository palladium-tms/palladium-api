class Case < Sequel::Model
  many_to_one :suite
  plugin :validation_helpers
  plugin :association_dependencies
  self.raise_on_save_failure = false
  plugin :timestamps
end
