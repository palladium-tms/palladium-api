require_relative 'management'
class Api < Sinatra::Base
  register Sinatra::CrossOrigin
  use JwtAuth
  attr_accessor :params
  def initialize
    super
  end

  before do
    content_type :json
    cross_origin
    body = request.body.read
    @params = JSON.parse(body) unless body == ''
  end

  # region products
  post '/products' do
    process_request request, 'products' do |_req, _username|
      positions = User[email: _username].product_position
      defarr = Array.new(positions.size).compact
      products = Product.all.map(&:values)
      products.delete_if do |element|
        index = positions.index(element[:id])
        if index
          defarr[index] = element
        else
          false
        end
      end
      { products: defarr + products}.to_json
    end
  end

  post '/product' do
    process_request request, 'product' do |_req, _username|
      { product: Product[id: params['product_data']['id']].values }.to_json
    end
  end

  post '/product_new' do
    process_request request, 'product_new' do |_req, _username|
      if params['product_data'].nil?
        { product_errors: ['product_data not found'] }.to_json
      elsif params['product_data']['name'].nil?
        { product_errors: ['name of product_data not found'] }.to_json
      else
        product = Product.create_new(params['product_data']['name'])
        if product[:product_errors]
          { product_errors: product[:product_errors] }.to_json
        else
          { product: product[:product].values }.to_json
        end
      end
    end
  end

  post '/product_edit' do
    process_request request, 'product_edit' do |_req, _username|
      if params['product_data']
        Product.edit(params['product_data']['id'], params['product_data']['name'])
      else
        { product_errors: { product: ['product_data not found'] } }.to_json
      end
    end
  end

  post '/product_delete' do
    process_request request, 'product_delete' do |_req, _username|
      errors = Product.product_id_validation(params['product_data']['id'])
      Product[id: params['product_data']['id']].destroy if errors.empty?
      status 200
      { product: params['product_data']['id'], errors: errors }.to_json
    end
  end
  # endregion products

  # region plans
  post '/plan_new' do
    process_request request, 'plan_new' do |_req, _username|
      objects = Plan.create_new(params)
      if objects[:plan_errors].nil? && objects[:product_errors].nil?
        { plan: objects[:plan].values, product: objects[:product].values }.to_json
      else
        status 422
        errors = { plan_errors: objects[:plan_errors] }
        errors[:product_errors] = objects[:product_errors] unless objects[:product_errors].nil?
        errors.to_json
      end
    end
  end

  post '/plans' do
    process_request request, 'plans' do |_req, _username|
      plans, errors = Product.get_plans(params['plan_data'])
      plans = Product.add_statictic(plans)
      status 422 unless errors
      { plans: plans, errors: errors }.to_json
    end
  end

  post '/plan' do
    process_request request, 'plan' do |_req, _username|
      plan = Plan[id: params['plan_data']['id']]
      plan = plan.values unless plan.nil?
      { plan: plan }.to_json
    end
  end

  post '/plan_edit' do
    process_request request, 'plan_edit' do |_req, _username|
      plan = Plan.edit(params)
      if plan[:plan_errors].nil?
        { plan: Product.add_statictic([*plan])[0] }
      else
        plan
      end.to_json
    end
  end

  post '/plan_delete' do
    process_request request, 'plan_delete' do |_req, _username|
      errors = Plan.plan_id_validation(params['plan_data']['id'])
      Plan[id: params['plan_data']['id']].destroy if errors.empty?
      { plan: params['plan_data']['id'], errors: errors }.to_json
    end
  end

  post '/plan_archive' do
    process_request request, 'plan_archive' do |_req, _username|
      plan = Plan.archive(params['plan_data']['id'])
      { plan: plan }.to_json
    end
  end
  # endregion plans

  # region runs
  post '/run_new' do
    process_request request, 'run_new' do |_req, _username|
      objects = Run.create_new(params)
      if objects[:product_errors].nil? && objects[:plan_errors].nil? && objects[:run_errors].nil?
        run = Plan.add_statictic([*objects[:run]]).first
        result = { run: run }
        result[:product] = objects[:product].values unless objects[:product].nil?
        result[:plan] = objects[:plan].values unless objects[:plan].nil?
        result[:suite] = objects[:suite].values unless objects[:suite].nil?
        result.to_json
      else
        status 422
        errors = { run_errors: objects[:run_errors] }
        errors[:product_errors] = objects[:product_errors] unless objects[:product_errors].nil?
        errors[:plan_errors] = objects[:plan_errors] unless objects[:plan_errors].nil?
        errors.to_json
      end
    end
  end

  post '/runs' do
    process_request request, 'runs' do |_req, _username|
      runs, errors = Plan.get_runs(params['run_data'])
      runs = Plan.add_statictic(runs)
      status 422 unless errors
      { runs: runs, errors: errors }.to_json
    end
  end

  post '/run' do
    process_request request, 'run' do |_req, _username|
      run = Run[id: params['run_data']['id']]
      if run
        { run: run.values }.to_json
      else
        { run: { errors: 'run not found' } }.to_json
      end
    end
  end

  post '/run_delete' do
    process_request request, 'run_delete' do |_req, _username|
      errors = Run.run_id_validation(params['run_data']['id'])
      Run[id: params['run_data']['id']].destroy if errors.empty?
      { run: params['run_data']['id'], errors: errors }.to_json
    end
  end
  # endregion runs

  # region result_set
  post '/result_set_new' do
    process_request request, 'result_set_new' do |_req, _username|
      objects = ResultSet.create_new(params)
      if objects[:product_errors].nil? && objects[:plan_errors].nil? && objects[:run_errors].nil? && objects[:result_sets_errors].nil?
        result = { result_sets: objects[:result_sets].map(&:values) }
        result[:product] = objects[:product].values unless objects[:product].nil?
        result[:plan] = objects[:plan].values unless objects[:plan].nil?
        result[:run] = objects[:run].values unless objects[:run].nil?
        result[:suite] = objects[:suite].values unless objects[:suite].nil?
        result.to_json
      else
        status 422
        errors = { result_sets_errors: objects[:result_sets_errors] }
        errors[:run_errors] = objects[:run_errors] unless objects[:run_errors].nil?
        errors[:product_errors] = objects[:product_errors] unless objects[:product_errors].nil?
        errors[:plan_errors] = objects[:plan_errors] unless objects[:plan_errors].nil?
        errors.to_json
      end
    end
  end

  post '/result_sets' do
    process_request request, 'result_sets' do |_req, _username|
      result_sets, errors = Run.get_result_sets(params['result_set_data'])
      status 422 unless errors
      { result_sets: result_sets.map(&:values), errors: errors }.to_json
    end
  end

  post '/result_set' do
    process_request request, 'result_set' do |_req, _username|
      result_set = ResultSet[id: params['result_set_data']['id']]
      if result_set
        { result_sets: [result_set.values] }.to_json
      else
        { result_sets: nil}.to_json
      end
    end
  end

  post '/result' do
    process_request request, 'result' do |_req, _username|
      { result: Result[id: params['result_data']['id']].values }.to_json
    end
  end

  post '/result_set_delete' do
    process_request request, 'result_set_delete' do |_req, _username|
      errors = []
      begin
        result_set_id = params['result_set_data']['id']
        ResultSet[id: result_set_id].remove_all_results
        ResultSet[id: result_set_id].delete
      rescue StandardError => e
        errors = e
      end
      { result_set: params['result_set_data'], errors: errors }.to_json
    end
  end

  post '/result_sets_by_status' do
    process_request request, 'result_sets_by_status' do |_req, _username|
      objects = ResultSet.get_result_sets_by_status(params)
      if objects[:product_errors].nil? && objects[:plan_errors].nil? &&
         objects[:run_errors].nil? && objects[:result_sets_errors].nil? &&
         objects[:status_errors].nil?
        result = {}
        result[:result_sets] = objects[:result_sets].map(&:values)
        result[:product] = objects[:product]
        result[:plan] = objects[:plan]
        result[:run] = objects[:run]
        result[:status] = objects[:status]
        result.to_json
      else
        status 422
        objects.to_json
      end
    end
  end

  # endregion result_set

  # region result
  post '/result_new' do
    process_request request, 'result_new' do |_req, _username|
      objects = Result.create_new(params)
      if objects[:product_errors].nil? && objects[:plan_errors].nil? &&
         objects[:run_errors].nil? && objects[:result_sets_errors].nil? &&
         objects[:status_errors].nil? && objects[:result_errors].nil?
        result = {}
        result[:result_sets] = objects[:result_sets].map(&:values) unless objects[:result_sets].nil?
        result[:product] = objects[:product].values unless objects[:product].nil?
        result[:plan] = objects[:plan].values unless objects[:plan].nil?
        result[:run] = objects[:run].values unless objects[:run].nil?
        result[:result] = objects[:result].values unless objects[:result].nil?
        result[:status] = objects[:status].values unless objects[:status].nil?
        result[:suite] = objects[:suite].values unless objects[:suite].nil?
        result.to_json
      else
        status 422
        objects.to_json
      end
    end
  end

  post '/results' do
    process_request request, 'results' do |_req, _username|
      results, errors = ResultSet.get_results(params['result_data'])
      status 422 unless errors
      { results: results.map(&:values), errors: errors }.to_json
    end
  end
  # endregion

  # region status
  post '/status_new' do
    process_request request, 'status_new' do |_req, _username|
      status = Status.create_new(params['status_data'])
      status 422 unless status.errors.empty?
      { status: status.values, errors: status.errors }.to_json
    end
  end

  post '/status_edit' do
    process_request request, 'status_edit' do |_req, _username|
      status = Status.edit(params['status_data'])
      status 422 unless status.errors.empty?
      { status: status.values, errors: status.errors }.to_json
    end
  end

  post '/statuses' do
    process_request request, 'statuses' do |_req, _username|
      statuses = Status.all
      statuses_ids = statuses.map(&:id)
      { statuses: Hash[statuses_ids.zip statuses.map(&:values)] }.to_json
    end
  end

  post '/not_blocked_statuses' do
    process_request request, 'not_blocked_statuses' do |_req, _username|
      statuses = Status.where(block: false)
      statuses_ids = statuses.map(&:id)
      { statuses: Hash[statuses_ids.zip statuses.map(&:values)] }.to_json
    end
  end
  # endregion

  # region suites
  post '/suites' do
    process_request request, 'suites' do |_req, _username|
      suites = Suite.where(product_id: params['suite_data']['product_id'])
      suites = Product.add_case_counts(suites)
      { suites: suites }.to_json
    end
  end

  post '/suite_edit' do
    process_request request, 'suite_edit' do |_req, _username|
      suite = Suite.edit(params['suite_data'])
      if suite.errors.empty?
        { suite: suite.values.merge(statistic: [{ status: 0,
                                                  count: 0 }]) }.to_json
      else
        { errors: suite.errors }.to_json
      end
    end
  end

  post '/suite_delete' do
    process_request request, 'suite_delete' do |_req, _username|
      begin
        suite = Suite[id: params['suite_data']['id']].destroy
      rescue StandardError => e
        errors = e
      end
      { suite: suite.values.merge(statistic: [{ 'suite_id' => 0, 'status' => 0, 'count' => 0 }]), errors: errors }.to_json
    end
  end
  # endregion

  # region cases
  post '/cases' do
    process_request request, 'cases' do |_req, _username|
      cases = Case.get_cases(params['case_data'])
      { cases: cases.map(&:values) }.to_json
    end
  end

  post '/case_edit' do
    process_request request, 'case_edit' do |_req, _username|
      this_case = Case.edit(params['case_data'])
      { case: this_case.values }.to_json
    end
  end

  post '/case_delete' do
    process_request request, 'case_delete' do |_req, _username|
      this_case = Case[params['case_data']['id']].destroy
      { case: this_case.values }.to_json
    end
  end
  # endregion

  # region history
  post '/case_history' do
    process_request request, 'case_history' do |_req, _username|
      start = Time.now
      $stdout.puts 'stdout'
      results = Case.get_history(params)
      $stdout.puts "##case_history# time: #{Time.now - start}"
      { history_data: results }.to_json
    end
  end
  # endregion

  # region invite_token
  # {"api_token_data" => {"name": string} }
  post '/create_invite_token' do
    process_request request, 'get_invite_token' do |_req, _username|
      invite = Invite.create_new(_username)
      { invite_data: invite.values }.to_json
    end
  end

  post '/get_invite_token' do
    process_request request, 'get_invite_token' do |_req, _username|
      if User[email: _username].invite.nil?
        { invite_data: nil }.to_json
      else
        { invite_data: User[email: _username].invite.values }.to_json
      end
    end
  end

  post '/check_link_validation' do
    process_request request, 'check_link_validation' do |_req, _username|
      valid_status, error = Invite.check_link_validation(params['token'])
      { validation: valid_status, errors: error }.to_json
    end
  end
  # endregion

  # region api_token
  # {"api_token_data" => {"name": string} }
  post '/token_new' do
    process_request request, 'token_new' do |_req, _username|
      result_token = Token.create_new(params['token_data'], JWT.encode(payload(_username), ENV['JWT_SECRET'], 'HS256'), _username)
      { token_data: result_token.values, errors: result_token.errors }.to_json
    end
  end

  post '/tokens' do
    process_request request, 'tokens' do |_req, _username|
      result_token = User[email: _username].tokens
      { tokens: result_token.map(&:values) }.to_json
    end
  end

  post '/token_delete' do
    process_request request, 'token_delete' do |_req, _username|
      Token[id: params['token_data']['id']].destroy
      { token: params['token_data']['id'] }.to_json
    end
  end
  # endregion

  # region product_position
  post '/set_product_position' do
    process_request request, 'set_product_position' do |_req, _username|
      if params['product_position'].is_a?(Array)
        user = User[email: _username]
        user.update(product_position: Sequel.pg_array(params['product_position']))
        { user: { email: user.email, product_position: user.product_position } }.to_json
      else
        { product_position_errors: 'product position must be array' }.to_json
      end
    end
  end
  # endregion product_position

  def process_request(req, scope)
    scopes, user = req.env.values_at :scopes, :user
    username = user['email']
    user_token = true
    user_token = User.user_token?(username, req.env['HTTP_AUTHORIZATION']) if scopes == %w(result_new result_sets_by_status)
    if scopes.include?(scope) && User[email: username].exists? && user_token
      yield req, username
    else
      halt 403
    end
  end

  def payload(email)
    {
      exp: Time.new(2050, 1, 1).to_i,
      iat: Time.now.to_i,
      iss: 'API',
      scopes: %w[result_new result_sets_by_status],
      user: {
        email: email
      }
    }
  end
end

class Public < Sinatra::Base
  register Sinatra::CrossOrigin

  post '/login' do
    cross_origin
    current_user = User.find(email: user_data[:email])
    if current_user.nil?
      halt 401, 'User or password not correct'
    elsif current_user.password != user_data[:password]
      halt 401, 'User or password not correct'
    else
      { token: token(user_data['email']) }.to_json
    end
  end

  get '/login' do
    erb :login
  end

  get '/up' do
    erb :up
  end

  get '/registration' do
    valid_status = Invite.check_link_validation(params['invite'])
    { token: params['invite'], validation: valid_status }.to_json
  end

  # region auth
  get '/logout' do
    session[:user] = nil
    redirect '/'
  end

  post '/registration' do
    cross_origin
    valid_status = Invite.check_link_validation(user_data['invite'])
    if User.all.empty? || (ENV['RACK_ENV'] == 'development' && params['invite'].nil?)
      valid_status[0] = true
      valid_status[1] = []
    end
    if valid_status.first
      new_user = User.create_new(user_data)
      { email: user_data['email'], errors: new_user.errors.values }.to_json
    else
      { email: user_data['email'], errors: valid_status[1] }.to_json
    end
  end

  post '/no_users' do
    cross_origin
    { no_users: User.empty? }.to_json
  end

  def user_data
    params['user_data']
  rescue StandardError => error
    error
  end

  def token(email)
    JWT.encode payload(email), ENV['JWT_SECRET'], 'HS256'
  end

  # header + . + payload + . + signature
  # header = type + algorithm
  def payload(email = nil)
    {
      exp: Time.now.to_i + 30 * 86_400,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      scopes: %w[products product product_new product_delete product_edit
                 plan_new plans plan plan_edit plan_delete plan_archive
                 run_new runs run run_delete
                 result_set_new result_sets result_set result_set_delete
                 result_new results
                 status_new statuses status_edit not_blocked_statuses
                 token_new tokens token_delete suites suite_edit
                 suite_delete cases case_delete case_edit result
                 case_history get_invite_token check_link_validation set_product_position],
      user: {
        email: email
      }
    }
  end

  post '/version' do
    { version: '0.4.0' }.to_json
  end
end
