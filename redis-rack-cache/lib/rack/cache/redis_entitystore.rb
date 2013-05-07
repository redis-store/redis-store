require 'rack/cache/entitystore'

module Rack
  module Cache
    class EntityStore
      class RedisBase < self
        # The underlying ::Redis instance used to communicate with the Redis daemon.
        attr_reader :cache

        extend Rack::Utils

        def open(key)
          data = read(key)
          data && [data]
        end

        def self.resolve(uri)
          new ::Redis::Factory.resolve(uri.to_s)
        end
      end

      class Redis < RedisBase
        def initialize(server, options = {})
          @cache = ::Redis::Factory.create(server)
        end

        def exist?(key)
          cache.exists key
        end

        def read(key)
          cache.get key
        end

        def write(body, ttl=0)
          buf = StringIO.new
          key, size = slurp(body){|part| buf.write(part) }

          ttl = [RedisRackCache.max_cache_seconds, ttl==0 ? RedisRackCache.max_cache_seconds : ttl].min
          [key, size] if cache.set(key, buf.string, :expire_in => ttl)
        end

        def purge(key)
          cache.del key
          nil
        end
      end

      REDIS = Redis
    end
  end
end
