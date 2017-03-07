class Status < Sequel::Model
  many_to_one :result_sets
  plugin :validation_helpers
  self.raise_on_save_failure = false
  self.plugin :timestamps

  def self.create_new(data)
    args = {}
    args['name'] = data.fetch('name', 'NoName')
    args['color'] = data.fetch('color', '#ffffff')
    status = self.new(args)
    status.valid?
    status.save
  end
end