# frozen_string_literal: true

class StaticData
  ADDRESS = '0.0.0.0'

  # @return [Integer] port for testing and development
  def self.port
    9292
  end
end

class DefaultValues
  # #region status
  DEFAULT_STATUS_COLOR = '#ffffff'
  # endregion status
end
