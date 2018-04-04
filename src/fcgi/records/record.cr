module Fcgi
  module Records
    class Record
      property version = 0_u32, record_type = 0_u32, request_id = 0_u32, content_length = 0_u32, padding_length = 0_u32
      property content_data = [] of UInt8, padding_data = [] of UInt8

      def self.from_io(io)
        version = version(io)
        type = int(io, UInt8)
        case type
        when Fcgi::FCGI_BEGIN_REQUEST
          BeginRequest.new(version, type, io)
        when Fcgi::FCGI_PARAMS
          Params.new(version, type, io)
        when Fcgi::FCGI_STDIN
          Stdin.new(version, type, io)
        when Fcgi::FCGI_DATA
          Stdin.new(version, type, io)
        when Fcgi::FCGI_STDOUT
          Stdout.new(version, type, io)
        when Fcgi::FCGI_STDERR
          Stderr.new(version, type, io)
        else
          Record.new(version, type, io)
        end
      end

      protected def self.int(io, type)
        io.read_bytes(type, IO::ByteFormat::BigEndian).to_u32
      end

      protected def self.version(io)
        version = int(io, UInt8)
        puts "BAD VERSION!!!" if version > Fcgi::FCGI_VERSION
        version
      end

      def initialize(version, type, io : IO)
        @version = version
        @record_type = type
        parse(io)
        puts to_s
      end

      def initialize(version, type, request_id, content_data)
        @version = version
        @record_type = type
        @request_id = request_id
        @content_length = 0
        @content_data = content_data
        @padding_length = 0
        @padding_data = "".bytes
      end

      def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::BigEndian)
        io.write_bytes(@version.to_u8, format)
        io.write_bytes(@record_type.to_u8, format)
        io.write_bytes(@request_id.to_u16, format)
        io.write_bytes(@content_length.to_u16, format)
        io.write_bytes(@padding_length.to_u8, format)
        io.write_bytes(0_u8, format)
        @content_data.each { |b| io.write_byte(b) }
        @padding_data.each { |b| io.write_byte(b) }
      end

      def to_s
        "#{"*" * 80}\n" \
        "FCGI Record : #{print_type}\n" \
        "version     : #{@version}\n" \
        "record_type : #{@record_type}\n" \
        "request_id  : #{@request_id}\n" \
        "content     : #{@content_length}:#{@content_data}\n" \
        "padding     : #{@padding_length}:#{@padding_data}"
      end

      protected def parse(io : IO)
        @request_id = int(io, UInt16)
        @content_length = int(io, UInt16)
        @padding_length = int(io, UInt8)
        io.skip(1) # 1 reserved byte
        @content_data = data(io, @content_length)
        @content_length = @content_data.size.to_u32 if @content_length > @content_data.size # why does this happen
        @padding_data = data(io, @padding_length)
      end

      protected def int(io : IO, type)
        Record.int(io, type)
      end

      protected def data(io : IO, length)
        text(io, length).bytes
      end

      protected def text(io : IO, length)
        ret = (io.read_string(length) || "")
        return ret
      rescue e : IO::EOFError
        puts "Read past end of data! #{length} (#{e.message})"
        return ""
      end

      protected def io_from_bytes(bytes)
        io = IO::Memory.new(bytes.size)
        bytes.each do |byte|
          io.write_byte(byte)
        end
        io.rewind
        io
      end

      private def print_type
        "FCGI"
      end
    end
  end
end
