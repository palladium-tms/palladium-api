# frozen_string_literal: true

class UserSetting < Sequel::Model
  one_to_one :user

  def before_create
    self.timezone = Time.now.getlocal.zone || Sequel::PalladiumSettings.timezone
    super
  end

  def self.edit(setting, params)
    setting.update(timezone: params['timezone'])
    { setting: setting.values }.to_json
  end
end
