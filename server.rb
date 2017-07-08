require_relative 'management'
class Api < Sinatra::Base
  # include Auth
  register Sinatra::CrossOrigin
  use JwtAuth

  def initialize
    super
  end

  before do
    content_type :json
    cross_origin
  end

  #region products
  get '/products' do
    process_request request, 'products' do |_req, _username|
      {products: Product.all.map(&:values)}.to_json
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
        product = Product[:id => params['product_data']['id']]
        product.remove_all_plans
        product.delete
      end
      content_type :json
      status 200
      {product: params['product_data']['id'], errors: errors}.to_json
    end
  end
  #endregion products

  #region plans
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
      { plans: plans, errors: errors }.to_json
    end
  end

  post '/plan_edit' do
    process_request request, 'plan_edit' do |_req, _username|
      plan = Plan.edit(params)
      status 422 unless plan[:errors].empty?
      plan.to_json
    end
  end

  post '/plan_delete' do
    process_request request, 'plan_delete' do |_req, _username|
      errors = Plan.plan_id_validation(params['plan_data']['id'])
      if errors.empty?
        Plan[:id => params['plan_data']['id']].destroy
      end
      {plan: params['plan_data']['id'], errors: errors}.to_json
    end
  end
  #endregion plans

  #region runs
  post '/run_new' do
    process_request request, 'run_new' do |_req, _username|
      run = Run.create_new(params)
      status 422 unless run.errors.empty?
      {'run' => run.values, "errors" => run.errors}.to_json
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

  post '/run_delete' do
    process_request request, 'run_delete' do |_req, _username|
      errors = Run.run_id_validation(params['run_data']['id'])
      if errors.empty?
        Run[:id => params['run_data']['id']].destroy
      end
      {run: params['run_data']['id'], errors: errors}.to_json
    end
  end

  post '/run_edit' do
    process_request request, 'run_edit' do |_req, _username|
      run = Run.edit(params)
      status 422 unless run[:errors].empty?
      run.to_json
    end
  end
  #endregion runs

  #region result_set
  post '/result_set_new' do
    process_request request, 'result_set_new' do |_req, _username|
      result_set = ResultSet.create_new(params)
      status 422 unless result_set.errors.empty?
      {result_set: result_set.values, errors: result_set.errors}.to_json
    end
  end

  post '/result_sets' do
    process_request request, 'result_sets' do |_req, _username|
      result_sets, errors = Run.get_result_sets(params['result_set_data'])
      status 422 unless errors
      {result_sets: result_sets.map(&:values), errors: errors}.to_json
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

  post '/result_set_edit' do
    process_request request, 'result_set_edit' do |_req, _username|
      result_set = ResultSet.edit(params)
      status 422 unless result_set[:errors].empty?
      result_set.to_json
    end
  end
  #endregion

  #region result
  post '/result_new' do
    process_request request, 'result_new' do |_req, _username|
      responce = Result.create_new(params)
      if responce[:errors].nil?
        {result: responce[:result].values, result_set_id: responce[:result_set_id]}.to_json
      else
        status 422
        {errors: responce[:errors].values, run_id: responce[:run_id]}.to_json
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
  #endregion

  #region status
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

  get '/statuses' do
    process_request request, 'statuses' do |_req, _username|
      statuses = Status.all
      statuses_ids = statuses.map(&:id)
      {statuses: Hash[(statuses_ids).zip statuses.map(&:values)]}.to_json
    end
  end
  #endregion


  def process_request(req, scope)
    scopes, user = req.env.values_at :scopes, :user
    username = user['email']
    if scopes.include?(scope) && User[email: username].exists?
      yield req, username
    else
      halt 403
    end
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

  get '/registration' do
    erb :registration
  end

  # region auth
  get '/logout' do
    session[:user] = nil
    redirect '/'
  end

  post '/registration' do
    new_user = User.create_new(user_data)
    begin
      new_user.save if new_user.errors.empty?
    rescue
    end
    if new_user.errors.empty?
      session[:user] = user_data['email']
      status 200
    else
      status 201
      content_type :json
      new_user.errors.to_json
    end
  end

  def user_data
    params['user_data']
  rescue StandardError => error
    error
  end

  def token(email)
    JWT.encode payload(email), ENV['JWT_SECRET'], 'HS256'
  end

  def payload(email)
    {
        exp: Time.now.to_i + 60 * 60,
        iat: Time.now.to_i,
        iss: ENV['JWT_ISSUER'],
        scopes: %w(products product_new product_delete product_edit
                   plan_new plans plan_edit plan_delete
                   run_new runs run_delete run_edit
                   result_set_new result_sets result_set_delete result_set_edit
                   result_new results
                   status_new statuses status_edit),
        user: {
            email: email
        }
    }
  end
end
