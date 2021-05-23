require 'sinatra'
require 'sequel'
require 'json'
require 'jwt'
require 'pg'
require 'sinatra/cross_origin'
require 'sinatra/custom_logger'
require 'logger'
require_relative 'database/database'
require_relative 'database/migrate/001_create_product_positions.rb'

# models
require_relative 'database/models/UserSetting'
require_relative 'database/models/User'
require_relative 'database/models/Product'
require_relative 'database/models/Plan'
require_relative 'database/models/Run'
require_relative 'database/models/ResultSet'
require_relative 'database/models/Result'
require_relative 'database/models/Status'
require_relative 'database/models/Token'
require_relative 'database/models/Invite'
require_relative 'database/models/Suite'
require_relative 'database/models/Case'

# migrations

# core modules
require_relative 'core/authorization/auth'
require_relative 'core/authorization/jwt_auth'
require_relative 'core/settings/palladium_settings'

