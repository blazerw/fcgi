module Fcgi
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
