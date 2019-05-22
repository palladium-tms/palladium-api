# require_relative '../lib/functions/AuthFunctions'
require_relative '../lib/functions/ProductFunctions'
require_relative '../lib/functions/PlanFunctions'
require_relative '../lib/functions/RunFunctions'
require_relative '../lib/functions/HistoryFunctions'
require_relative '../lib/functions/ResultSetFunctions'
require_relative '../lib/functions/ResultFunctions'
require_relative '../lib/functions/StatusFunctions'
require_relative '../lib/functions/TokenFunctions'
require_relative '../lib/functions/InviteTokenFunctions'
require_relative '../lib/functions/SuiteFunctions'
require_relative '../lib/functions/ProductPositionFunctions'
require_relative '../lib/functions/CaseFunctions'
require_relative '../lib/functions/UserSetting'
require_relative '../lib/helpers/string_helper'
# require_relative '../lib/functions/AccountFunctions'
require_relative 'ObjectWrap/http'
require 'json'

  class User
    include UserSetting
    include TokenFunctions
    include ProductPosition
    include ResultFunctions
    include SuiteFunctions
    include PlanFunctions
    include ProductFunctions
    include ResultSetFunctions
    include RunFunctions
    include StatusFunctions
    include HistoryFunctions
    include CaseFunctions
    include InviteTokenFunctions
    include StringHelper
    attr_accessor :email, :password, :token, :http
    def initialize(options = {})
      @email = options[:email]
      @password = options[:password]
      @http = Http.new
    end

    def login
      puts "Login from #{@email} #{@password}"
      response = @http.post_request('/public/login', { 'user_data': {'email': @email, 'password': @password}})
      @token = JSON.parse(response.body)['token']
      @http = Http.new(token:  @token)
      response
    end

    def token=(token)
      @token = token
      @http = Http.new(token:  @token)
    end

    def post_request(path, params = nil)
      @http.post_request(path, params)
    end
  end
