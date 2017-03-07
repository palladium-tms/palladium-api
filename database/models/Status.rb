class Status < Sequel::Model
  many_to_one :result_sets
  plugin :validation_helpers
  self.raise_on_save_failure = false
  self.plugin :timestamps

  def validate
    validates_unique :name
    validates_format /^.{1,40}$/, :name
    validates_format /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/, :color
  end

  def self.create_new(data)
    data['color'] = data.fetch('color', '#ffffff')
    status = self.new(data)
    status.save if status.valid?
    status
  end
end