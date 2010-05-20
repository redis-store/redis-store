module ActionController
  module Session
# Redis session storage for Rails, and for Rails only. Derived from
# the MemCacheStore code, simply dropping in Redis instead.
#
# Options:
#  :key     => Same as with the other cookie stores, key name
#  :secret  => Encryption secret for the key
#  :host    => Redis host name, default is localhost
#  :port    => Redis port, default is 6379
#  :db      => Database number, defaults to 0. Useful to separate your session storage from other data
#  :key_prefix  => Prefix for keys used in Redis, e.g. myapp-. Useful to separate session storage keys visibly from others
#  :expire_after => A number in seconds to set the timeout interval for the session. Will map directly to expiry in Redis

    class RedisSessionStore < ActionController::Session::AbstractStore

      def initialize(app, options = {})
        # Support old :expires option
        options[:expire_after] ||= options[:expires]

        super

        @options = { :key_prefix => "" }.update(options)
        servers = [options[:servers]].flatten.compact.map do |server_options|
          {
            :namespace => 'rack:session',
            :host => 'localhost',
            :port => '6379',
            :db => 0
          }.update(Redis::Factory.convert_to_redis_client_options(server_options))
        end

        @pool = Redis::Factory.create(*servers)
      end

      private
      def prefixed(sid)
        "#{@options[:key_prefix]}#{sid}"
      end

      def get_session(env, sid)
        sid ||= generate_sid
        begin
          session = @pool.marshalled_get(prefixed(sid)) || {}
        rescue Errno::ECONNREFUSED
          session = {}
        end
        [sid, session]
      end

      def set_session(env, sid, session_data)
        options = env['rack.session.options']
        @pool.marshalled_set(prefixed(sid), session_data, options)
        return true
      rescue Errno::ECONNREFUSED
        return false
      end

    end
  end
end
