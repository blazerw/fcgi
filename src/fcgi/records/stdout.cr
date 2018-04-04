module Fcgi
  module Records
    class Stdout < Record
      def initialize(version, type, io : IO)
        super
      end

      def initialize(version, type, request_id, content_data)
        super
        @content_data = content_data
        @content_length = @content_data.size
      end

      private def print_type
        "(#{Fcgi::FCGI_STDOUT}) FCGI_STDOUT"
      end
    end
  end
end
