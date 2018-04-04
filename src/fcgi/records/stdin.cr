module Fcgi
  module Records
    class Stdin < AbstractData
      def to_s
        "#{super}\n" \
        "#{"*" * 80}"
      end

      private def print_type
        "(#{Fcgi::FCGI_STDIN}) FCGI_STDIN"
      end
    end
  end
end
