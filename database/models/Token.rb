class Token < Sequel::Model
  many_to_one :user
  plugin :validation_helpers
  self.raise_on_save_failure = false
  plugin :timestamps

  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
    errors.add(:token, 'cannot be empty') if !token || token.empty?
  end

  # @param [Hash] data
  # example: {"api_token_data" => {"name": string} }
  def self.create_new(data, token, _username)
    new_token = Token.create(name: data['name'], token: token)
    User[email: _username].add_token(new_token)
    new_token
  end

  #
  # def self.product_id_validation(plan, product_id)
  #   case
  #     when product_id.nil?
  #       plan.errors.add('product_id', "product_id can't be nil")
  #       return plan
  #     when Product[id: product_id].nil?
  #       plan.errors.add('product_id', "product_id is not belongs to any product")
  #       return plan
  #   end
  #   plan
  # end
  #
  # def self.plan_id_validation(plan_id)
  #   case
  #     when plan_id.nil?
  #       return {'plan_id' => ["plan_id can't be nil"]}
  #     when plan_id.empty?
  #       return {'plan_id' => ["plan_id can't be empty"]}
  #     when Plan[id: plan_id].nil?
  #       return {'plan_id' => ["plan_id is not belongs to any product"]}
  #   end
  #   []
  # end
  #
  # # @param [Hash] data
  # # example: {'plan_data': {'product_id': id, 'name': name}} or {'plan_data': {'product_name': name, 'name': name}}
  # def self.create_new(data)
  #   data['plan_data']['product_id'] ||= Product.find_or_create(name: data['plan_data']['product_name']).id
  #   begin
  #     plan = Plan.find_or_create(name: data['plan_data']['name'], product_id: data['plan_data']['product_id']) {|plan|
  #       plan.name = data['plan_data']['name']
  #     }
  #   rescue StandardError
  #     return self.product_id_validation(Plan.new(data['plan_data']), data['plan_data']['product_id'])
  #   end
  #   Product[id: data['plan_data']['product_id']].add_plan(plan)
  # end
  #
  # # @param data [Hash] like {'plan_data' => {id: int, plan_name: str}}
  # def self.edit(data)
  #   begin
  #     plan = Plan[:id => data['plan_data']['id']]
  #     plan.update(:name => data['plan_data']['plan_name'], :updated_at => Time.now)
  #     plan.valid?
  #     {'plan_data': plan.values, 'errors': plan.errors}
  #   rescue StandardError
  #     {'plan_data': Plan.new.values, 'errors': [params: 'Plan data is incorrect FIXME!!']} # FIXME: add validate
  #   end
  # end
  #
  # def self.get_runs(*args)
  #   plan =  Plan[:id => args.first['plan_id']]
  #   begin
  #     [plan.runs, []]
  #   rescue StandardError
  #     [[], 'Run data is incorrect']
  #   end
  # end
  #
  # def self.get_statistic(runs)
  #   ResultSet.where(:run_id => runs.map(&:id)).group_and_count(:run_id, :status).map(&:values).group_by do |e|
  #     e[:run_id]
  #   end
  # end
  #
  # def self.add_statictic(runs)
  #   statistic = get_statistic(runs)
  #   runs.map(&:values).map do |run|
  #     run.merge!({statistic: statistic[run[:id]] || []})
  #   end
  # end
end
