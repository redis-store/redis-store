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
          new ::Redis::Store::Factory.resolve(uri.to_s)
        end
      end

      class Redis < RedisBase
        def initialize(server, options = {})
          @cache = ::Redis::Store::Factory.create(server)
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

          if ttl.zero?
            [key, size] if cache.set(key, buf.string)
          else
            [key, size] if cache.setex(key, ttl, buf.string)
          end
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
