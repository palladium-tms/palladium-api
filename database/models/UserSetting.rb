class UserSetting < Sequel::Model
  one_to_one :user

  def before_create
    self.timezone = Time.now.getlocal.zone || Sequel::PalladiumSettings.timezone
    super
  end
end
