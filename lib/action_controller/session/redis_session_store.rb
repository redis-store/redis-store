require "redis-store"

module RedisStore
  module Rack
    module Session
      # Redis session storage for Rails, and for Rails only. Derived from
      # the MemCacheStore code, simply dropping in Redis instead.
      #
      # Options:
      #  :key          => Same as with the other cookie stores, key name
      #  :secret       => Encryption secret for the key
      #  :host         => Redis host name, default is localhost
      #  :port         => Redis port, default is 6379
      #  :db           => Database number, defaults to 0. Useful to separate your session storage from other data
      #  :key_prefix   => Prefix for keys used in Redis, e.g. myapp-. Useful to separate session storage keys visibly from others
      #  :expire_after => A number in seconds to set the timeout interval for the session. Will map directly to expiry in Redis
      module Rails
        def initialize(app, options = {})
          # Support old :expires option
          options[:expire_after] ||= options[:expires]

          super

          options = options.dup
          servers = [ options.delete(:servers) ].flatten.compact
          servers = [ "redis://localhost:6379/0" ] if servers.empty?
          servers.map! do |server|
            server = Redis::Factory.convert_to_redis_client_options(server)
            server.merge(options)
          end

          @pool = Redis::Factory.create(*servers)
        end

        private
          def get_session(env, sid)
            sid ||= generate_sid
            begin
              session = @pool.get(sid) || {}
            rescue Errno::ECONNREFUSED
              session = {}
            end
            [sid, session]
          end

          def set_session(env, sid, session_data)
            options = env['rack.session.options']
            @pool.set(sid, session_data, options)
            return(::Redis::Store.rails3? ? sid : true)
          rescue Errno::ECONNREFUSED
            return false
          end

          def destroy(env)
            if sid = current_session_id(env)
              @pool.del(sid)
            end
          rescue Errno::ECONNREFUSED
            false
          end
      end
    end
  end
end

if ::Redis::Store.rails3?
  class ActionDispatch::Session::RedisSessionStore < ActionDispatch::Session::AbstractStore
    include RedisStore::Rack::Session::Rails
  end
else
  class ActionController::Session::RedisSessionStore < ActionController::Session::AbstractStore
    include RedisStore::Rack::Session::Rails
  end
end
