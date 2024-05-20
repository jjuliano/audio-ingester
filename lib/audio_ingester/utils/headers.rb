module AudioIngester
  module Utils
    module Headers
      def get_wav_header
        # begin on byte 16
        @io.seek(16)

        # get the 4-byte integer after byte 16 to obtain the Subchunk1Size
        subchunk1_size = @io.read(4).unpack1('V')

        # Read the rest of the subchunk based on subchunk1_size
        return @io.read(subchunk1_size)
      end
    end
  end
end
