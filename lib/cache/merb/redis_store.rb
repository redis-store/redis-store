module Merb
  module Cache
    class RedisStore < AbstractStore
      # Instantiate the store.
      #
      # Example:
      #   RedisStore.new                                     # => host: localhost,   port: 6379,  db: 0
      #   RedisStore.new :servers => ["example.com"]         # => host: example.com, port: 6379,  db: 0
      #   RedisStore.new :servers => ["example.com:23682"]   # => host: example.com, port: 23682, db: 0
      #   RedisStore.new :servers => ["example.com:23682/1"] # => host: example.com, port: 23682, db: 1
      #   RedisStore.new :servers => ["localhost:6379/0", "localhost:6380/0"] # => instantiate a cluster
      def initialize(config = {})
        addresses = extract_addresses(config[:servers])
        @data = if addresses.size > 1
          DistributedMarshaledRedis.new addresses
        else
          MarshaledRedis.new addresses.first || {}
        end
      end

      def writable?(key, parameters = {}, conditions = {})
        true
      end

      def read(key, parameters = {}, conditions = {})
        @data.get normalize(key, parameters), conditions
      end

      def write(key, data = nil, parameters = {}, conditions = {})
        if writable?(key, parameters, conditions)
          method = conditions && conditions[:unless_exist] ? :set_unless_exists : :set
          @data.send method, normalize(key, parameters), data, conditions
        end
      end

      def write_all(key, data = nil, parameters = {}, conditions = {})
        write(key, data, parameters, conditions)
      end

      def fetch(key, parameters = {}, conditions = {}, &blk)
        if data = read(key, parameters)
          data
        elsif block_given?
          data = yield
          write(key, data, parameters)
          data
        end
      end

      def exists?(key, parameters = {})
        @data.key? normalize(key, parameters)
      end

      def delete(key, parameters = {})
        @data.delete normalize(key, parameters)
      end

      def delete_all
        @data.flush_db
      end

      def delete_all!
        delete_all
      end

      private
        def extract_addresses(addresses) # TODO extract in a module or a class
          return [] unless addresses
          addresses = addresses.flatten.compact
          addresses.inject([]) do |result, address|
            host, port = address.split /\:/
            port, db   = port.split /\// if port
            address = {}
            address[:host] = host if host
            address[:port] = port if port
            address[:db]  = db.to_i if db
            result << address
            result
          end
        end

        # Returns cache key calculated from base key
        # and SHA2 hex from parameters.
        def normalize(key, parameters = {})
          parameters.empty? ? "#{key}" : "#{key}--#{parameters.to_sha2}"
        end
    end
  end
end
