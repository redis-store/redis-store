require 'rack/session/abstract/id'
require 'redis-store'

module Rack
  module Session
    class Redis < Abstract::ID
      attr_reader :mutex, :pool

      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge \
        :namespace    => 'rack:session',
        :redis_server => 'redis://127.0.0.1:6379/0'

      def initialize(app, options = {})
        super

        @mutex = Mutex.new
        options[:redis_server] ||= @default_options[:redis_server]
        @pool = ::Redis::Factory.create options
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
        expiry = options[:expire_after]
        expiry = expiry.nil? ? 0 : expiry + 1

        with_lock(env, false) do
          @pool.set session_id, expiry, new_session
          session_id
        end
      end

      def destroy_session(env, session_id, options)
        with_lock(env) do
          @pool.delete(session_id)
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

