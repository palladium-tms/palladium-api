source 'https://rubygems.org'

group :server do
  gem 'bcrypt'
  gem 'jwt'
  gem 'pg'
  gem "puma", ">= 5.3.1" # web server
  gem 'sequel' # gem for work with database
  gem 'sinatra' # main web framework
  gem 'sinatra-contrib'
  gem 'sinatra-cross_origin'
end

group :test do
  gem 'faker'
  gem 'rspec'
  gem 'palladium'
end