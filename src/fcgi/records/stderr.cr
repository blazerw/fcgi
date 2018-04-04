module Fcgi
  module Records
    class Stderr < Record
      def initialize(version, type, io : IO)
        super
      end

      def initialize(version, type, request_id, content_data)
        super
        @content_data = content_data
        @content_length = @content_data.size
      end

      private def print_type
        "(#{Fcgi::FCGI_STDERR}) FCGI_STDERR"
      end
    end
  end
end
