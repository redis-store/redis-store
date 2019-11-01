class Redis
  class Store < self
    module Compression
      MINIMUM_BYTESIZE = 1024

      def set(key, val, options = nil)
        compress(val) { |value| super(key, value, options) }
      end

      def setex(key, ttl, val, options = nil)
        compress(val) { |value| super(key, ttl, value, options) }
      end

      def setnx(key, val, options = nil)
        compress(val) { |value| super(key, value, options) }
      end

      def get(key, options = nil)
        decompress super(key, options)
      end

      protected

      def compress(raw)
        value = if compress?(raw)
                  compressor.deflate(raw)
                else
                  raw
                end

        yield value
      end

      def decompress(raw)
        return value unless compress?

        value = compressor.inflate(raw) rescue raw

        value.force_encoding('utf-8')
      end

      private

      def compressor
        case @compressor
        when :gzip, true
          Gzip
        when :deflate
          Deflate
        else
          @compressor
        end
      end

      def compress?(raw = nil)
        !raw.nil? && !compressor.nil? && raw.bytesize >= MINIMUM_BYTESIZE
      end
    end
  end
end
