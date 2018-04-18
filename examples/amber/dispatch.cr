require "http/request"
require "fcgi"

fastcgi_log = File.open("fastcgi.cr.log", "a")
STDOUT.reopen fastcgi_log
STDERR.reopen fastcgi_log
STDOUT.sync = true

STDOUT.puts "Before Startup:"
STDOUT.puts "ENV  : #{ENV.inspect}"
STDOUT.puts "RAILS_ENV : #{ENV["RAILS_ENV"]}"
STDOUT.puts "RACK_ENV  : #{ENV.fetch("RACK_ENV", "missing")}"
STDOUT.puts "AMBER_ENV: #{ENV.fetch("AMBER_ENV", "missing")}"
STDOUT.puts "HOME: #{ENV.fetch("HOME", "missing")}"

ENV["DISPATCH_FCGI"] = "true"

# Basic environment
ENVIRONMENT="development"
ENV["RAILS_ENV"] ||= ENVIRONMENT
ENV["RACK_ENV"] ||= ENV["RAILS_ENV"]
ENV["AMBER_ENV"] ||= ENV["RAILS_ENV"]
ENV["HOME"] ||= `echo ~`.strip
ENV["HOSTNAME"] ||= "v3.familygiftswap.com"

# After env setup, or fgs will set it to "development".
require "./src/amber_world.cr"

class MyTCPServer < TCPServer
  def initialize(@fd : Int32, @family : Family, @type : Type, @protocol : Protocol, blocking = false)
    @closed = false
    init_close_on_exec(@fd)

    self.sync = true
    unless blocking
      self.blocking = false
    end
  end
end

app = AmberWorld.new

logger = app.logger

logger.debug "Application Startup:"
logger.debug "ENV  : #{ENV.inspect}"
logger.debug "RAILS_ENV : #{ENV["RAILS_ENV"]}"
logger.debug "RACK_ENV  : #{ENV["RACK_ENV"]}"
logger.debug "AMBER_ENV: #{ENV["AMBER_ENV"]}"
logger.debug "HOME: #{ENV["HOME"]}"

stop_me = false

srv = MyTCPServer.new(STDIN.fd, Socket::Family::INET, Socket::Type::STREAM, Socket::Protocol::RAW)

Signal::INT.trap do
  puts "INT"
  stop_me = true
  srv.close
end
Signal::QUIT.trap do
  puts "QUIT"
  stop_me = true
  srv.close
end
Signal::ABRT.trap do
  puts "ABRT"
  stop_me = true
  srv.close
end
Signal::KILL.trap do
  puts "KILL"
  stop_me = true
  srv.close
end
Signal::STOP.trap do
  puts "STOP"
  stop_me = true
  srv.close
end
Signal::TERM.trap do
  puts "TERM"
  stop_me = true
  srv.close
end
Signal::HUP.trap {
  puts "HUP"
  stop_me = true
  srv.close
}
Signal::USR1.trap {
  puts "USR1"
  stop_me = true
}

def puts_error(e)
  puts "Error: #{e.message}"
  puts e.inspect
  if e.backtrace
    puts "Backtrace\n"
    puts e.backtrace.join("\n")
  else
    puts "No backtrace!"
  end
end

until stop_me
  begin
    srv.accept do |client|

      request = Fcgi::Request.new(client)

      response_io = IO::Memory.new(512)
      response = HTTP::Server::Response.new(response_io, request.version)

      response.version = request.version
      response.reset
      # response.headers["Connection"] = "keep-alive" if request.keep_alive?
      context = HTTP::Server::Context.new(request.to_request, response)
      begin
        app.call(context)
      rescue ex
        puts_error(ex)
      end

      # if response.upgraded?
      #   must_close = false
      #   return
      # end
      response.output.close

      response_io.rewind

      puts "status_code:#{context.response.status_code}"
      response = Fcgi::Response.from_response(response_io, context.response.status_code.to_u32, request.request_id)

      begin
        response.send(client)
        puts "Response sent."
      rescue errno : Errno
        puts "Got a libc err: (#{errno.errno}) #{errno.message}"
        puts_error(errno)
      ensure
        puts "Closing..."
        client.close # testing this, flag from Dreamhost says application closes
                     # when request finished
        puts "Closed"
      end
    end
  rescue io : IO::Error
    puts "Outside loop IO."
    puts_error(io)
  rescue e
    puts "Outside loop."
    puts_error(e)
  ensure
    puts "dispatch.cr ensure"
  end
end
puts "Exiting!"
