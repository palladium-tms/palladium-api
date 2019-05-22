require 'net/http'
require 'json'
require_relative '../../../spec/lib/ObjectWrap/http'
module UserSetting
  def get_setting
    @http.post_request('/api/user_setting')
  end
end
