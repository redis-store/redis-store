module Rack
  module Cache
    class EntityStore
      class RedisBase < EntityStore
        # The underlying ::Redis instance used to communicate with the Redis daemon.
        attr_reader :cache

        extend Rack::Utils

        def open(key)
          data = read(key)
          data && [data]
        end

        def self.resolve(uri)
          db = uri.path.sub(/^\//, '')
          db = "0" if db.empty?
          server = { :host => uri.host, :port => uri.port || "6379", :db => db, :password => uri.password }
          new server
        end
      end

      class Redis < RedisBase
        def initialize(server, options = {})
          @cache = ::Redis.new server
        end

        def exist?(key)
          cache.exists key
        end

        def read(key)
          cache.get key
        end

        def write(body)
          buf = StringIO.new
          key, size = slurp(body){|part| buf.write(part) }
          [key, size] if cache.set(key, buf.string)
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
