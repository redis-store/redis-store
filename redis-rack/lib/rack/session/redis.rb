require 'rack/session/abstract/id'
require 'redis-store'

module Rack
  module Session
    class Redis < Abstract::ID
      attr_reader :mutex, :pool

      DEFAULT_REDIS_SERVER = 'redis://127.0.0.1:6379/0/rack:session'

      def initialize(app, options = {})
        super

        @mutex = Mutex.new
        @pool = ::Redis::Factory.create options[:redis_server] || DEFAULT_REDIS_SERVER
      end

      def generate_sid
        loop do
          sid = super
          break sid unless @pool.get(sid, true) # <=== WTF? <tt>true</tt>
        end
      end

      def get_session(env, sid)
        with_lock(env, [nil, {}]) do
          unless sid and session = @pool.get(sid)
            sid, session = generate_sid, {}
            unless /^OK/ =~ @pool.set(sid, session)
              raise "Session collision on '#{sid.inspect}'"
            end
          end
          [sid, session]
        end
      end

      def set_session(env, session_id, new_session, options)
        expiry = options[:expire_after] || 1

        with_lock(env, false) do
          @pool.set session_id, new_session, {:expire_after => expiry}
          session_id
        end
      end

      def destroy_session(env, session_id, options)
        with_lock(env) do
          @pool.del(session_id)
          generate_sid unless options[:drop]
        end
      end

      def with_lock(env, default=nil)
        @mutex.lock if env['rack.multithread']
        yield
      rescue Errno::ECONNREFUSED
        if $VERBOSE
          warn "#{self} is unable to find Redis server."
          warn $!.inspect
        end
        default
      ensure
        @mutex.unlock if @mutex.locked?
      end

    end
  end
end

