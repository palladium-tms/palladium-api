require_relative '../management'
require 'yaml'
# sleep 10 # FIXME: need to add wait for database available
DB = Sequel.connect(YAML.load_file('config/sequel.yml')[Sinatra::Application.environment])

DB.create_table? :users do
  primary_key :id
  String :email
  String :password
end

DB.create_table? :tokens do
  primary_key :id
  String :name
  String :token
  foreign_key :user_id, :users
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
  Integer :plan_id
  Integer :status, default: 0
  DateTime :created_at
  DateTime :updated_at
end

DB.create_table? :statuses do
  primary_key :id
  String :name
  Boolean :block, default: false
  String :color, default: '#ffffff'
end

DB.create_table? :results do
  primary_key :id
  foreign_key :status_id, :statuses
  String :message
  DateTime :created_at
end

DB.create_table? :result_sets_results do
  primary_key :id
  foreign_key :result_id, :results
  foreign_key :result_set_id, :result_sets
end
SuitesAndCases.apply(DB, :up)