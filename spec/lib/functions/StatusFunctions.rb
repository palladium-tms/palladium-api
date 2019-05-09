require 'net/http'
require 'json'
module StatusFunctions
  def create_new_status(options = {})
    options[:name] ||= rand_status_name
    response = @http.post_request('/api/status_new', StatusFunctions.params(options))
    AbstractStatus.new(response)
  end

  def get_all_statuses
    response = @http.post_request('/api/statuses')
    AbstractStatusPack.new(response)
  end

  def get_not_blocked_statuses
    response = @http.post_request('/api/not_blocked_statuses')
    AbstractStatusPack.new(response)
  end

  def status_edit(options = {})
    response = @http.post_request('/api/status_edit', StatusFunctions.params(options))
    AbstractStatus.new(response)
  end

  def self.params(param)
    params = { status_data: {} }
    params[:status_data][:id] = param[:id] if param[:id]
    params[:status_data][:name] = param[:name] if param[:name]
    params[:status_data][:color] = param[:color] if param[:color]
    params[:status_data][:block] = param[:block] unless param[:block].nil?
    params
  end
end
