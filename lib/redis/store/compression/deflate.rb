class Redis
  class Store < self
    module Compression
      # Compress data over the wire with Deflate.
      module Deflate
        extend self

        def inflate(data)
          Zlib::Inflate.inflate(data)
        end

        def deflate(data)
          Zlib::Deflate.deflate(data)
        end
      end
    end
  end
end
