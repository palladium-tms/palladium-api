Sequel.extension :migration
class SuitesAndCases < Sequel::Migration
  def up
    DB.create_table? :suites do
      primary_key :id
      foreign_key :product_id, :products
      String :name
      DateTime :created_at
      DateTime :updated_at
    end

    DB.create_table? :cases do
      primary_key :id
      foreign_key :suite_id, :suites
      String :name
      DateTime :created_at
      DateTime :updated_at
    end
  end
end