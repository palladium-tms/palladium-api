# frozen_string_literal: true

require_relative '../data/static_data'
require_relative 'ObjectWrap/http'
module Palladium
  def http
    @http = Http.new
  end
end
