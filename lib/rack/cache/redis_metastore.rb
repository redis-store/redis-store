module Rack
  module Cache
    class MetaStore
      class RedisBase < MetaStore
        extend Rack::Utils

        # The Redis::Store object used to communicate with the Redis daemon.
        attr_reader :cache

        def self.resolve(uri)
          new ::Redis::Factory.convert_to_redis_client_options(uri.to_s)
        end
      end

      class Redis < RedisBase
        def initialize(server, options = {})
          options[:redis_server] ||= server
          @cache = ::Redis::Factory.create options
        end

        def read(key)
          key = hexdigest(key)
          cache.get(key) || []
        end

        def write(key, entries)
          key = hexdigest(key)
          cache.set(key, entries)
        end

        def purge(key)
          cache.del(hexdigest(key))
          nil
        end
      end

      REDIS = Redis
    end
  end
end
