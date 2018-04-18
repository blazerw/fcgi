require "../config/*"
require "./middleware/*"

# Amber::Server.start

class AmberWorld
  def initialize
    version = "[Amber #{Amber::VERSION}]".colorize(:light_cyan).to_s
    logger.debug "Initializing Amber App #{version} environemnt #{(ENV["AMBER_ENV"]).colorize(:green)}"
    logger.debug "session:#{session.inspect}"
    if ENV["DISPATCH_FCGI"]? == "true"
      logger.debug "\tInitialize for dispatch.fcgi"
      app.handler.prepare_pipelines
    else
      logger.debug "\tInitialize for normal"
      app.run
    end
  end

  def call(context)
    app.handler.call(context)
    logger.debug "App response.headers:#{context.response.headers.to_s}"
    logger.debug "context.response:#{context.response.inspect}"
  end

  def logger
    app.settings.logger
  end

  def session
    app.settings.session
  end

  private def app
    Amber::Server.instance
  end
end

AmberWorld.new unless ENV["DISPATCH_FCGI"]? == "true"
