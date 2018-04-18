class FcgiContentType < Amber::Pipe::Base
  def call(context : HTTP::Server::Context)
    add_header_if_missing(context.response.headers)
    call_next context
  end

  def add_header_if_missing(headers)
    headers.add("Content-Type", "text/html") unless headers.fetch("Content-Type", nil) && headers.fetch("Location", nil)
  end
end
