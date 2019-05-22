require 'net/http'
require 'json'
module HistoryFunctions
  def case_history(options = {})
    response = @http.post_request('/api/case_history', case_data: {id: options})
    AbstractHistoryPack.new(response)
  end
end