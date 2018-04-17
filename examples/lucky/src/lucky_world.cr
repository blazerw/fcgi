require "./server"
require "logger"

class LuckyWorld
  property logger : Logger
  property handler_pipeline : HTTP::Handler

  def initialize
    @logger = Logger.new(STDOUT)
    version = "[Lucky #{Lucky::VERSION}]".colorize(:light_cyan).to_s
    logger.debug "Initializing App #{version} environemnt #{(ENV["LUCKY_ENV"]).colorize(:green)}"
    @handler_pipeline = HTTP::Server.build_middleware(HANDLERS)
    if ENV["DISPATCH_FCGI"]? == "true"
      logger.debug "\tInitialize for dispatch.fcgi"
    else
      logger.debug "\tInitialize for normal"
    end
  end

  def call(context)
    @handler_pipeline.call(context)
  end

  def logger(io = STDOUT)
    @logger ||= Logger.new(io)
  end

  def self.read_environment(path)
    File.read_lines(path).each do |line|
      puts "line:#{line}|"
      # var, value = line.not_nil!.split("=") do |part|
      ary = [] of String
      line.not_nil!.split("=", 2) do |part|
        puts "part:#{part}|"
        ary << part.strip
      end
      if ary.size == 2
        ENV[ary[0]] = ary[1]
      end
    end
  end
end
