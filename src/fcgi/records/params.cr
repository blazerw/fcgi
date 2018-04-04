module Fcgi
  module Records
    class Params < Record
      property params = {} of String => String | Nil

      protected def parse(io : IO)
        super(io)
        read_params
      end

      def to_s
        "#{super}\n" \
        "params      : #{@params}\n" \
        "#{"*" * 80}"
      end

      private def read_params
        io = io_from_bytes(@content_data)
        while io.pos < io.size
          name_length = param_length(io)
          value_length = param_length(io)
          name = text(io, name_length)
          value = text(io, value_length)
          @params[name.to_s] = value.to_s
        end
      end

      private def param_length(io)
        test_byte = int(io, UInt8)
        return test_byte if (test_byte >> 7) == 0
        b3 = test_byte & 0x7f
        b2 = int(io, UInt8)
        b1 = int(io, UInt8)
        b0 = int(io, UInt8)
        (b3 << 24) + (b2 << 16) + (b1 << 8) + b0
      end

      private def print_type
        "(#{Fcgi::FCGI_PARAMS}) FCGI_PARAMS"
      end

      private def min_param_length
        2
      end
    end
  end
end
