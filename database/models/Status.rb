class Status < Sequel::Model
  one_to_many :results
  plugin :validation_helpers
  self.raise_on_save_failure = false
  self.plugin :timestamps

  def validate
    validates_format /^.{1,40}$/, :name
    validates_format /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/, :color
  end

  def self.create_new(data)
    if Status[:name => data['name']].nil?
      data['color'] = data.fetch('color', '#ffffff')
      status = self.new(data)
      status.save if status.valid?
      status # TODO: it needed?
    else
      Status[:name => data['name']].unblock!
    end
  end

  def unblock!
    self.update(:block => false)
    self # TODO: it needed?
  end

  def block!
    self.update(:block => true)
    self # TODO: it needed?
  end
end