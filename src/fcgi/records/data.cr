module Fcgi
  module Records
    class Data < AbstractData
      def to_s
        "#{super}\n" \
        "#{"*" * 80}"
      end

      private def print_type
        "(#{Fcgi::FCGI_DATA}) FCGI_DATA"
      end
    end
  end
end
