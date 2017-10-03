require_relative 'management'
class Api < Sinatra::Base
  register Sinatra::CrossOrigin
  use JwtAuth

  def initialize
    super
  end

  before do
    content_type :json
    cross_origin
  end

  # region products
  post '/products' do
    process_request request, 'products' do |_req, _username|
      {products: Product.all.map(&:values)}.to_json
    end
  end

  post '/product' do
    process_request request, 'product' do |_req, _username|
      {product: Product[id: params['product_data']['id']].values}.to_json
    end
  end

  post '/product_new' do
    process_request request, 'product_new' do |_req, _username|
      product = Product.create_new(params)
      {product: product.values, errors: product.errors}.to_json
    end
  end

  post '/product_edit' do
    process_request request, 'product_edit' do |_req, _username|
      Product.edit(params['product_data']['id'], params['product_data']['name'])
    end
  end

  post '/product_delete' do
    process_request request, 'product_delete' do |_req, _username|
      errors = Product.product_id_validation(params['product_data']['id'])
      if errors.empty?
        product = Product[id: params['product_data']['id']]
        product.remove_all_suites
        product.destroy
      end
      content_type :json
      status 200
      {product: params['product_data']['id'], errors: errors}.to_json
    end
  end
  # endregion products

  # region plans
  post '/plan_new' do
    process_request request, 'plan_new' do |_req, _username|
      plan = Plan.create_new(params)
      status 422 unless plan.errors.empty?
      {plan: plan.values, errors: plan.errors}.to_json
    end
  end

  post '/plans' do
    process_request request, 'plans' do |_req, _username|
      plans, errors = Product.get_plans(params['plan_data'])
      plans = Product.add_statictic(plans)
      status 422 unless errors
      {plans: plans, errors: errors}.to_json
    end
  end

  post '/plan' do
    process_request request, 'plan' do |_req, _username|
      plan = Plan[id: params['plan_data']['id']]
      plan = plan.values unless plan.nil?
      {plan: plan}.to_json
    end
  end

  post '/plan_edit' do
    process_request request, 'plan_edit' do |_req, _username|
      plan = Plan.edit(params)
      status 422 unless plan['errors'].empty?
      plan.to_json
    end
  end

  post '/plan_delete' do
    process_request request, 'plan_delete' do |_req, _username|
      errors = Plan.plan_id_validation(params['plan_data']['id'])
      if errors.empty?
        Plan[id: params['plan_data']['id']].destroy
      end
      {plan: params['plan_data']['id'], errors: errors}.to_json
    end
  end
  # endregion plans

  # region runs
  post '/run_new' do
    process_request request, 'run_new' do |_req, _username|
      run, other_data = Run.create_new(params)
      status 422 unless run.errors.empty?
      {'run' => run.values, 'errors' => run.errors, other_data: other_data}.to_json
    end
  end

  post '/runs' do
    process_request request, 'runs' do |_req, _username|
      runs, errors = Plan.get_runs(params['run_data'])
      runs = Plan.add_statictic(runs)
      status 422 unless errors
      {runs: runs, errors: errors}.to_json
    end
  end

  post '/run' do
    process_request request, 'run' do |_req, _username|
      {run: Run[id: params['run_data']['id']].values}.to_json
    end
  end

  post '/run_delete' do
    process_request request, 'run_delete' do |_req, _username|
      errors = Run.run_id_validation(params['run_data']['id'])
      if errors.empty?
        Run[id: params['run_data']['id']].destroy
      end
      {run: params['run_data']['id'], errors: errors}.to_json
    end
  end
  # endregion runs

  # region result_set
  post '/result_set_new' do
    process_request request, 'result_set_new' do |_req, _username|
      result_set, other = ResultSet.create_new(params)
      status 422 unless result_set.errors.empty?
      {result_set: result_set.values, errors: result_set.errors, other_data: other}.to_json
    end
  end

  post '/result_sets' do
    process_request request, 'result_sets' do |_req, _username|
      result_sets, errors = Run.get_result_sets(params['result_set_data'])
      status 422 unless errors
      {result_sets: result_sets.map(&:values), errors: errors}.to_json
    end
  end

  post '/result_set' do
    process_request request, 'result_set' do |_req, _username|
      {result_set: ResultSet[id: params['result_set_data']['id']].values}.to_json
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
      {result_set: params['result_set_data'], errors: errors}.to_json
    end
  end
  #
  # post '/result_set_edit' do
  #   process_request request, 'result_set_edit' do |_req, _username|
  #     result_set = ResultSet.edit(params)
  #     status 422 unless result_set['errors'].empty?
  #     result_set.to_json
  #   end
  # end
  # endregion

  # region result
  post '/result_new' do
    process_request request, 'result_new' do |_req, _username|
      responce, other = Result.create_new(params)
      if responce[:errors].nil?
        {result: responce.values, other_data: other}.to_json
      else
        status 422
        {errors: responce.errors.values, other_data: other}.to_json
      end
    end
  end

  post '/results' do
    process_request request, 'results' do |_req, _username|
      results, errors = ResultSet.get_results(params['result_data'])
      status 422 unless errors
      {results: results.map(&:values), errors: errors}.to_json
    end
  end
  # endregion

  # region status
  post '/status_new' do
    process_request request, 'status_new' do |_req, _username|
      status = Status.create_new(params['status_data'])
      status 422 unless status.errors.empty?
      {status: status.values, errors: status.errors}.to_json
    end
  end

  post '/status_edit' do
    process_request request, 'status_edit' do |_req, _username|
      status = Status.edit(params['status_data'])
      status 422 unless status.errors.empty?
      {status: status.values, errors: status.errors}.to_json
    end
  end

  post '/statuses' do
    process_request request, 'statuses' do |_req, _username|
      statuses = Status.all
      statuses_ids = statuses.map(&:id)
      {statuses: Hash[statuses_ids.zip statuses.map(&:values)]}.to_json
    end
  end

  post '/not_blocked_statuses' do
    process_request request, 'not_blocked_statuses' do |_req, _username|
      statuses = Status.where({block: false})
      statuses_ids = statuses.map(&:id)
      {statuses: Hash[statuses_ids.zip statuses.map(&:values)]}.to_json
    end
  end
  # endregion

  # region suites
  post '/suites' do
    process_request request, 'suites' do |_req, _username|
      suites = Suite.where(product_id: params['suite_data']['product_id'])
      suites = Product.add_case_counts(suites)
      {suites: suites}.to_json
    end
  end

  post '/suite_edit' do
    process_request request, 'suite_edit' do |_req, _username|
      begin
        suite = Suite.edit(params['suite_data'])
      rescue StandardError => e
        errors = e
      end
      {suite: suite.values.merge({statistic: [{'suite_id' => suite.id, 'status' => 0, 'count' => 0}]}), errors: errors}.to_json
    end
  end

  post '/suite_delete' do
    process_request request, 'suite_delete' do |_req, _username|
      begin
        suite = Suite[id: params['suite_data']['id']].destroy
      rescue StandardError => e
        errors = e
      end
      {suite: suite.values.merge({statistic: [{'suite_id' => 0, 'status' => 0, 'count' => 0}]}), errors: errors}.to_json
    end
  end
  # endregion

  # region cases
  post '/cases' do
    process_request request, 'cases' do |_req, _username|
      cases = Case.get_cases(params['case_data'])
      {cases: cases.map(&:values)}.to_json
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
      {case: this_case.values}.to_json
    end
  end
  # endregion

  # region api_token
  # {"api_token_data" => {"name": string} }
  post '/token_new' do
    process_request request, 'token_new' do |_req, _username|
      result_token = Token.create_new(params['token_data'], JWT.encode(self.payload(_username), ENV['JWT_SECRET'], 'HS256'), _username)
      {token_data: result_token.values, errors: result_token.errors}.to_json
    end
  end

  post '/tokens' do
    process_request request, 'tokens' do |_req, _username|
      result_token = User[email: _username].tokens
      {tokens: result_token.map(&:values)}.to_json
    end
  end

  post '/token_delete' do
    process_request request, 'token_delete' do |_req, _username|
      Token[id: params['token_data']['id']].destroy
      {token: params['token_data']['id']}.to_json
    end
  end
  # endregion

  def process_request(req, scope)
    scopes, user = req.env.values_at :scopes, :user
    username = user['email']
    user_token = true
    user_token = User.user_token?(username, req.env['HTTP_AUTHORIZATION']) if scopes == ['result_new']
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
        scopes: %w[result_new],
        user: {
            email: email
        }
    }
  end
end

class Public < Sinatra::Base
  include Auth
  register Sinatra::CrossOrigin

  post '/login' do
    cross_origin
    if auth_success?(user_data)
      content_type :json
      {token: token(user_data['email'])}.to_json
    else
      halt 401
    end
  end

  get '/login' do
    erb :login
  end

  get '/up' do
    erb :up
  end

  get '/registration' do
    erb :registration
  end

  # region auth
  get '/logout' do
    session[:user] = nil
    redirect '/'
  end

  post '/registration' do
    cross_origin
    new_user = User.create_new(user_data)
    begin
      new_user.save
    rescue
    end
    content_type :json
    status 200
    status 401 unless new_user.errors.empty?
    {email: user_data['email'], errors: new_user.errors}.to_json
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
        exp: Time.now.to_i + 60 * 600,
        iat: Time.now.to_i,
        iss: ENV['JWT_ISSUER'],
        scopes: %w[products product product_new product_delete product_edit
                 plan_new plans plan plan_edit plan_delete
                 run_new runs run run_delete
                 result_set_new result_sets result_set result_set_delete
                 result_new results
                 status_new statuses status_edit not_blocked_statuses token_new tokens
                 token_delete suites suite_edit suite_delete cases case_delete case_edit],
          user: {
              email: email
          }
      }
  end
end
