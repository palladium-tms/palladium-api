require 'sinatra'
require 'sequel'
require 'sqlite3'
require 'json'
require_relative 'database/database'

# models
require_relative 'database/models/User'

# core moduls
require_relative 'core/auth'

# utilits
require_relative 'utilits/encrypt'
