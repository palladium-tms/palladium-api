# frozen_string_literal: true

require 'securerandom'
require 'time'
class Invite < Sequel::Model
  plugin :timestamps, force: true, update_on_create: true
  one_to_one :user

  def self.create_new(username = nil)
    unless username.nil?
      if User[email: username].nil?
        halt 400, 'Username is incorrect or not exist'
      else
        invite = Invite.create(token: SecureRandom.hex)
        invite.expiration_data = invite.created_at + 10 * 60
        User[email: username].invite&.destroy
        User[email: username].invite = invite
      end
    end
    invite
  end

  def self.check_link_validation(link)
    if link.nil? || Invite[token: link].nil?
      [false, ['token_not_found']]
    elsif (Invite[token: link].expiration_data - Time.now).negative?
      [false, ['token is expired']]
    else
      [true, []]
    end
  end
end
