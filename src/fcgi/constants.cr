module Fcgi
  # FCGI constants
  FCGI_VERSION            = 1_u32

  #
  # Values for type component of FCGI_Header
  #
  FCGI_BEGIN_REQUEST      = 1_u32
  FCGI_ABORT_REQUEST      = 2_u32
  FCGI_END_REQUEST        = 3_u32
  FCGI_PARAMS             = 4_u32
  FCGI_STDIN              = 5_u32
  FCGI_STDOUT             = 6_u32
  FCGI_STDERR             = 7_u32
  FCGI_DATA               = 8_u32
  FCGI_GET_VALUES         = 9_u32
  FCGI_GET_VALUES_RESULT  = 10_u32
  FCGI_UNKNOWN_TYPE       = 11_u32
  FCGI_MAXTYPE            = FCGI_UNKNOWN_TYPE

  #
  # Mask for flags component of FCGI_BeginRequestBody
  #
  FCGI_KEEP_CONN          = 1

  #
  # Listening socket file number
  #
  FCGI_LISTENSOCK_FILENO  = 0

  #
  # Values for protocolStatus component of FCGI_EndRequestBody
  #
  FCGI_REQUEST_COMPLETE = 0_u8
  FCGI_CANT_MPX_CONN    = 1_u8
  FCGI_OVERLOADED       = 2_u8
  FCGI_UNKNOWN_ROLE     = 3_u8

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

  class Response
    property records = [] of Records::Record
    property request_id = 0_u32

    def self.from_response(io : IO, status_code : UInt32, request_id : UInt32)
      my_response = new(request_id)
      io.rewind if io.pos > 0
      puts "skip:#{io.gets}" # skip first line
      text = "Status: #{status_code}\n"
      text = text + io.gets_to_end
      if text.nil?
        text = ""
      end
      my_response.build(text, status_code)
      my_response
    end

    def initialize(request_id : UInt32)
      @request_id = request_id
    end

    def build(text : String, status_code = HTTP_STATUS_OK)
      puts "build status_code:#{status_code}"
      @records << text_record(text)
      @records << text_record("")
      @records << end_request_record(status_code)
    end

    def send(client : IO)
      records.each do |record|
        puts "#{record.to_s}"
        record.to_io(client)
      end
    end

    private def text_record(text : String)
      puts "TEXT:\n#{text}"
      Records::Stdout.new(FCGI_VERSION, FCGI_STDOUT, @request_id, text.bytes)
    end

    private def end_request_record(code : UInt32)
      io = IO::Memory.new(8)
      io.write_bytes(code, IO::ByteFormat::BigEndian)
      io.write_bytes(FCGI_REQUEST_COMPLETE.to_u8, IO::ByteFormat::BigEndian)
      io.write_bytes(0_u8, IO::ByteFormat::BigEndian)
      io.write_bytes(0_u8, IO::ByteFormat::BigEndian)
      io.write_bytes(0_u8, IO::ByteFormat::BigEndian)
      content_data = [] of UInt8
      io.rewind
      io.each_byte do |b|
        content_data << b
      end
      Records::EndRequest.new(FCGI_VERSION, FCGI_END_REQUEST, request_id, content_data)
    end
  end
end
