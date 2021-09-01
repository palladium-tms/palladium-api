root = Dir.getwd.to_s
bind "unix://#{root}/tmp/puma/socket/puma.sock"
bind 'tcp://0.0.0.0:80'
pidfile "#{root}/tmp/puma/pid/puma.pid"
stdout_redirect "#{root}/tmp/puma/log/stdout", "#{root}/tmp/puma/log/stderr", true
