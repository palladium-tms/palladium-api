require 'net/http'
require 'json'
require_relative '../../../spec/lib/ObjectWrap/http'
module InviteTokenFunctions
  def create_new_invite_token
    @http.post_request('/api/create_invite_token', {})
  end

  def get_invite
    @http.post_request('/api/get_invite_token', {})
  end

  def check_link_validation(token)
    @http.post_request('/api/check_link_validation', { token: token })
  end
end
