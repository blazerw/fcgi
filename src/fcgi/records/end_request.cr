module Fcgi
  module Records
    class EndRequest < Record
      def initialize(version, type, io : IO)
        super
      end

      def initialize(version, type, request_id, content_data)
        super
        @content_data = content_data
        @content_length = @content_data.size
      end

      def to_s
        "#{super}\n" \
        "#{"*" * 80}"
      end

      private def print_type
        "(#{Fcgi::FCGI_END_REQUEST}) FCGI_END_REQUEST"
      end
    end
  end
end
