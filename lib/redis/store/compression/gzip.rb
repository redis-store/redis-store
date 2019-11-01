class Redis
  class Store < self
    module Compression
      # Compress data over the wire with GZip.
      module Gzip
        extend self
        # Compress the given data with GZip.
        #
        # @param [String] data - Uncompressed data.
        # @return [String]
        def deflate(data)
          io = StringIO.new(String.new(""), "w")
          gz = Zlib::GzipWriter.new(io)

          gz.write(data)
          gz.close

          io.string
        end

        # Decompress the given data with GZip.
        #
        # @param [String] data - Compressed data.
        # @return [String] Decompressed data.
        def inflate(data)
          io = StringIO.new(data, "rb")
          gz = Zlib::GzipReader.new(io)

          gz.read
        end
      end
    end
  end
end
