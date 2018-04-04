module Fcgi
  class Request
    property records = [] of Records::Record
    property request_id = 0_u32, method = "GET", version = "HTTP/1.1", resource = ""
    property headers : HTTP::Headers, query_string = "", body = ""

    def initialize(client : IO)
      @headers = HTTP::Headers.new
      begin_records(client)
      params_records(client)
      stdin_records(client)
      puts "got records: #{@records.size}"
    end

    def to_request
      request = HTTP::Request.new(@method, @resource, @headers, @body, @version)
      request.query = @query_string
      request.body = @body
      # request.query_params
      request
    end

    private def begin_records(client : IO)
      @records << Records::Record.from_io(client)
      @request_id = @records.first.request_id
    end

    private def params_records(client : IO)
      until_empty(client) do |generic|
        record = generic.as(Records::Params)
        @method = not_nil(record.params["REQUEST_METHOD"])
        @resource = not_nil(record.params["PATH_INFO"])
        @query_string = not_nil(record.params["QUERY_STRING"])
        headers(record.params)
        @version = not_nil(record.params["SERVER_PROTOCOL"])
      end
    end

    private def not_nil(thing)
      if thing.nil?
        ""
      else
        thing
      end
    end

    private def headers(params)
      params.each_key do |key|
        if key.starts_with?("HTTP_") || key.starts_with?("CONTENT_")
          header_key = string_to_dasherized_camelcase(key.gsub(/^HTTP_/, ""))
          val = params[key] || ""
          @headers.add(header_key, val)
        end
      end
      puts "headers:#{@headers.inspect}"
      @headers
    end

    private def string_to_dasherized_camelcase(value)
      parts = value.split("_")
      new_parts = [] of String
      parts.each do |part|
        new_parts << (part.capitalize)
      end
      new_parts.join("-")
    end

    private def stdin_records(client : IO)
      until_empty(client) do |generic|
        record = generic.as(Records::Stdin)
        @body = @body + record.body
      end
    end

    private def until_empty(client : IO,)
      until_empty(client) {|r| }
    end
    private def until_empty(client : IO, &block)
      count = 0
      while count < 100
        @records << Records::Record.from_io(client)
        break if @records.last.content_length == 0_u32
        yield(@records.last)
        count += 1
      end
    end
  end
end
