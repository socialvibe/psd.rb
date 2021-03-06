class PSD
  module ImageFormat
    # Parses an RLE compressed image
    module RLE
      private

      def parse_rle!
        @byte_counts = parse_byte_counts!
        parse_channel_data!
      end

      def parse_byte_counts!
        byte_counts = []
        (channels * height).times do |i|
          byte_counts << @file.read_short
        end

        return byte_counts
      end

      def parse_channel_data!
        @chan_pos = 0
        @line_index = 0

        channels.times do |i|
          PSD.logger.debug "Parsing RLE channel ##{i}: file position = #{@file.tell}, image position = #{@chan_pos}, line = #{@line_index}"
          decode_rle_channel
          @line_index += height
        end
      end

      def decode_rle_channel
        height.times do |j|
          byte_count = @byte_counts[@line_index + j]
          finish = @file.tell + byte_count

          while @file.tell < finish
            len = @file.read_byte

            if len < 128
              len += 1
              @channel_data.insert @chan_pos, *@file.read(len).bytes.to_a
              @chan_pos += len
            elsif len > 128
              len ^= 0xff
              len += 2

              val = @file.read(1).bytes.to_a
              @channel_data.insert @chan_pos, *(val * len) 
              @chan_pos += len
            end
          end
        end
      end
    end
  end
end