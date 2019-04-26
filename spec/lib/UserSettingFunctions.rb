require 'net/http'
require 'json'
require_relative '../../spec/lib/ObjectWrap/http'
module UserSetting

  def self.get_setting(http)
    http.post_request('/api/user_setting')
  end
end