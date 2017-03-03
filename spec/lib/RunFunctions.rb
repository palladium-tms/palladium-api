require 'net/http'
require 'json'
class RunFunctions
  # @param [Hash] args must has 'run_data[plan_id]' with plan id, and can has run_data[name] with name (or will be generate
  # random name). example: {"run_data[name]" => "string", "run_data[plan_id]" => int }
  def self.create_new_run(*args)
    args.first['run_data[name]'] ||= 30.times.map { StaticData::ALPHABET.sample }.join
    request = Net::HTTP::Post.new('/run_new', 'Content-Type' => 'application/json')
    request.set_form_data(args.first)
    [request, args.first['run_data[name]']]
  end
end