# frozen_string_literal: true

require 'net/http'
require 'json'
require_relative '../../../spec/lib/ObjectWrap/http'
module UserSetting
  def get_setting
    @http.post_request('/api/user_setting')
  end

  def update_user_setting(params = {})
    @http.post_request('/api/user_setting_edit', user_settings: params)
  end
end
