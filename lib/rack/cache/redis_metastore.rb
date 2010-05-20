module Rack
  module Cache
    class MetaStore
      class RedisBase < MetaStore
        extend Rack::Utils

        # The Redis::MarshaledClient object used to communicate with the Redis daemon.
        attr_reader :cache

        def self.resolve(uri)
          db = uri.path.sub(/^\//, '')
          db = "0" if db.empty?
          server = { :host => uri.host, :port => uri.port || "6379", :db => db }
          new server
        end
      end

      class Redis < RedisBase
        def initialize(server, options = {})
          @cache = ::Redis::MarshaledClient.new server
        end

        def read(key)
          key = hexdigest(key)
          cache.marshalled_get(key) || []
        end

        def write(key, entries)
          key = hexdigest(key)
          cache.marshalled_set(key, entries)
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
