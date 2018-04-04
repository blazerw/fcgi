module Fcgi
  module Records
    class BeginRequest < Record
      property role : UInt32 = 0_u32, flags : UInt32 = 0_u32, keep_conn : Bool = false

      protected def parse(io : IO)
        super(io)
        app_flags
      end

      private def app_flags
        io = io_from_bytes(@content_data)
        @role = int(io, UInt16)
        @flags = int(io, UInt8)
        @keep_conn = (flags & Fcgi::FCGI_KEEP_CONN) == 1
        io.close
      end

      def to_s
        "#{super}\n" \
        "role        : #{@role}\n" \
        "flags       : #{print_bits(@flags)}\n" \
        "keep_conn   : #{@keep_conn}\n" \
        "#{"*" * 80}"
      end

      protected def print_bits(byte)
        out = ""
        8.downto(1) do |i|
          out += "#{byte.bit(i)}"
        end
        out
      end

      private def print_type
        "(#{Fcgi::FCGI_BEGIN_REQUEST}) FCGI_BEGIN_REQUEST"
      end
    end
  end
end
