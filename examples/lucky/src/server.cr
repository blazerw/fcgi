require "./app"

host = Lucky::Server.settings.host
port = Lucky::Server.settings.port

HANDLERS = [
  Lucky::HttpMethodOverrideHandler.new,
  Lucky::LogHandler.new,
  Lucky::SessionHandler.new,
  Lucky::Flash::Handler.new,
  Lucky::ErrorHandler.new(action: Errors::Show),
  Lucky::RouteHandler.new,
  Lucky::StaticFileHandler.new("./public", false),
]

unless Lucky::Env.production?
  server = HTTP::Server.new(host, port, HANDLERS)

  puts "Listening on http://#{host}:#{port}"

  Signal::INT.trap do
    server.close
  end

  server.listen
end
