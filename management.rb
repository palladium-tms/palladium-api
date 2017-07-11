require 'sinatra'
require 'sequel'
require 'json'
require 'jwt'
require 'pg'
require 'sinatra/cross_origin'
require_relative 'database/database'

# models
require_relative 'database/models/User'
require_relative 'database/models/Product'
require_relative 'database/models/Plan'
require_relative 'database/models/Run'
require_relative 'database/models/ResultSet'
require_relative 'database/models/Result'
require_relative 'database/models/Status'

# core modules
require_relative 'core/authorization/auth'
require_relative 'core/authorization/jwt_auth'

# utilits
require_relative 'utilits/encrypt'