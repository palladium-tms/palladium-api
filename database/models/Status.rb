class Status < Sequel::Model
  one_to_many :results
  plugin :validation_helpers
  self.raise_on_save_failure = false
  self.plugin :timestamps

  def validate
    validates_presence [:name]
    validates_format /^.{1,40}$/, :name
  end

  def self.create_new(data)
    if Status[:name => data['status_name']].nil?
      params = { name: data['status_name'] }
      params.merge!({color: data['status_color']}) unless data['status_color'].nil?
      status = self.new(params)
      status.save if status.valid?
      status # TODO: it needed?
    else
      Status[:name => data['status_name']].unblock!
    end
  end

  def self.edit(*args)
    status = Status[:id => args.first['id']]
    if status.nil?
      [Status.new, 'Status data is invalid'] # Fixme: need validation
    else
      params = {}
      params.merge!({name: args.first['name']}) if args.first['name']
      params.merge!({color: args.first['color']}) if args.first['color']
      params.merge!({block: args.first['block']}) if args.first['block']
      status.update(params)
      status
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