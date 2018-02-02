class Status < Sequel::Model
  one_to_many :results
  plugin :validation_helpers
  self.raise_on_save_failure = false
  plugin :timestamps

  def validate
    validates_presence [:name]
    validates_format /^.{1,40}$/, :name
  end

  # @param [Hash] data can contains only :color and :name
  def self.create_new(data)
    name = data['name'] || data[:name]
    if Status[name: name]
      Status[name: name].unblock!
      return Status[name: name]
    end
    color = data['color'] unless data['color'].nil?
    status = new(name: name, color: color)
    if status.valid?
      status.save
    else
      { status_errors: status.errors.full_messages }
    end
  end

  def self.edit(options)
    status = Status[id: options['id']]
    if status.nil?
      [Status.new, 'Status data is invalid'] # FIXME: need validation
    else
      params = {}
      params[:name] = options['name'] if options['name']
      params[:color] = options['color'] if options['color']
      params[:block] = options['block'] unless options['block'].nil?
      status.update(params)
      status
    end
  end

  def self.status_exist?(data)
    if data['result_data']
      return !Status.find(name: data['result_data']['status']).nil? unless data['result_data']['status'].nil?
    end
    false
  end

  def unblock!
    update(block: false)
    self # TODO: it needed?
  end

  def block!
    update(block: true)
    self # TODO: it needed?
  end
end
