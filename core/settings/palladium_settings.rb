# frozen_string_literal: true

require 'json'
module Sequel
  module PalladiumSettings
    def self.settings
      @settings ||= JSON.parse(File.read('config/palladium.json'))
    end

    def self.timezone
      settings['timezone'] unless settings['timezone'].to_s.empty?
    end
  end
end
