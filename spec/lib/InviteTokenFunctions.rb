require 'net/http'
require 'json'
require_relative '../../spec/lib/ObjectWrap/http'
class InviteTokenFunctions
  def self.create_new_invite_token(http)
    http.post_request('/api/create_invite_token', {})
  end

  def self.get_invite(http)
    http.post_request('/api/get_invite_token', {})
  end

  def self.check_link_validation(http, token)
    http.post_request('/api/check_link_validation', { token: token })
  end
end