require_relative '../management'
DB = Sequel.connect('sqlite://palladium.db') # requires sqlite3

DB.create_table? :users do
  primary_key :id
  String :email
  String :password
end

DB.create_table? :products do
  primary_key :id
  String :name
  DateTime :created_at
  DateTime :updated_at
end

DB.create_table? :plans do
  primary_key :id
  foreign_key :product_id, :products
  String :name
  DateTime :created_at
  DateTime :updated_at
end

DB.create_table? :runs do
  primary_key :id
  foreign_key :plan_id, :plans
  String :name
  DateTime :created_at
  DateTime :updated_at
end

DB.create_table? :result_sets do
  primary_key :id
  foreign_key :run_id, :runs
  String :name
  Integer :status, default: 0
  DateTime :created_at
  DateTime :updated_at
end