module Fcgi
  module Records
    class AbstractData < Record
      property body = ""

      def to_s
        "#{super}\n" \
        "body        : #{@body}\n"
      end

      protected def parse(io : IO)
        super(io)
        @body = @content_data.map(&.chr).join("")
      end
    end
  end
end
