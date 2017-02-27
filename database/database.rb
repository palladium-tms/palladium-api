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
end
