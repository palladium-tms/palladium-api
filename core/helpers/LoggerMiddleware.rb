module Logger
  def call(env)
    env['logger'] = @logger
    @app.call(env)
  end
end