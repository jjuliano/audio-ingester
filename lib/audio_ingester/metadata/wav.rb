require_relative "../metadata"
require_relative "../utils/headers"
require 'debug'
module AudioIngester
  module Metadata
    module WavFile
      # Note: header starts to read from from subchunk1_size

      def format
        # Audio format (2 bytes)
        audio_format_id = @header[0..1].unpack1('v')
        case audio_format_id
        when 0x01 then
          "PCM"
        else
          sprintf("Compressed")
        end
      end

      def channel_count
        @header[2..3].unpack1('v') # Num Channels (2 bytes)
      end

      def sampling_rate
        @header[4..7].unpack1('V') # Sample Rate (4 bytes)
      end

      def bit_depth
        @header[14..15].unpack1('v') # Bits Per Sample (2 bytes)
      end

      def byte_rate
        @header[8..11].unpack1('V') # Byte Rate (4 bytes)
      end

      def bit_rate
        sampling_rate * channel_count * bit_depth  # Bit rate formula
      end
    end
  end
end
