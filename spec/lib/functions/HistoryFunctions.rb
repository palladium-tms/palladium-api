# frozen_string_literal: true

require 'net/http'
require 'json'
module HistoryFunctions
  def case_history(case_data = {})
    response = @http.post_request('/api/case_history', case_data:)
    AbstractHistoryPack.new(response)
  end
end
