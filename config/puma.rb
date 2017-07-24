root = Dir.getwd.to_s
bind 'tcp://0.0.0.0:80'
bind "unix://#{root}/tmp/puma/socket/puma.sock"
pidfile "#{root}/tmp/puma/pid/puma.pid"
stdout_redirect "#{root}/tmp/puma/log/stdout", "#{root}/tmp/puma/log/stderr", true