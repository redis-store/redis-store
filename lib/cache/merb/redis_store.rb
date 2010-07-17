module Merb
  module Cache
    class RedisStore < AbstractStore
      # Instantiate the store.
      #
      # Example:
      #   RedisStore.new
      #     # => host: localhost,   port: 6379,  db: 0
      #
      #   RedisStore.new :servers => ["example.com"]
      #     # => host: example.com, port: 6379,  db: 0
      #
      #   RedisStore.new :servers => ["example.com:23682"]
      #     # => host: example.com, port: 23682, db: 0
      #
      #   RedisStore.new :servers => ["example.com:23682/1"]
      #     # => host: example.com, port: 23682, db: 1
      #
      #   RedisStore.new :servers => ["example.com:23682/1/theplaylist"]
      #     # => host: example.com, port: 23682, db: 1, namespace: theplaylist
      #
      #   RedisStore.new :servers => ["localhost:6379/0", "localhost:6380/0"]
      #     # => instantiate a cluster
      def initialize(config = { })
        @data = Redis::Factory.create config[:servers]
      end

      def writable?(key, parameters = {}, conditions = {})
        true
      end

      def read(key, parameters = {}, conditions = {})
        @data.get normalize(key, parameters), conditions
      end

      def write(key, data = nil, parameters = {}, conditions = {})
        if writable?(key, parameters, conditions)
          method = conditions && conditions[:unless_exist] ? :setnx : :set
          @data.send method, normalize(key, parameters), data, conditions
        end
      end

      def write_all(key, data = nil, parameters = {}, conditions = {})
        write key, data, parameters, conditions
      end

      def fetch(key, parameters = {}, conditions = {}, &blk)
        read(key, parameters) || (write key, yield, parameters, conditions if block_given?)
      end

      def exists?(key, parameters = {})
        @data.exists normalize(key, parameters)
      end

      def delete(key, parameters = {})
        @data.del normalize(key, parameters)
      end

      def delete_all
        @data.flushdb
      end

      def delete_all!
        delete_all
      end

      private
        # Returns cache key calculated from base key
        # and SHA2 hex from parameters.
        def normalize(key, parameters = {})
          parameters.empty? ? "#{key}" : "#{key}--#{parameters.to_sha2}"
        end
    end
  end
end
