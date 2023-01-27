# frozen_string_literal: true

class Token < Sequel::Model
  many_to_one :user
  plugin :validation_helpers
  self.raise_on_save_failure = false
  plugin :timestamps, force: true, update_on_create: true

  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
    errors.add(:token, 'cannot be empty') if !token || token.empty?
  end

  # @param [Hash] data
  # @param [String] token is a jwt token
  # @param [String] username
  # example: {"api_token_data" => {"name": string} }
  def self.create_new(data, token, username)
    new_token = Token.create(name: data['name'], token:)
    User[email: username].add_token(new_token)
    new_token
  end
end
