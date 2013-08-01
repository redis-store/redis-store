require 'rack/session/abstract/id'
require 'redis-store'
require 'thread'

module Rack
  module Session
    class Redis < Abstract::ID
      attr_reader :mutex, :pool

      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge \
        :redis_server => 'redis://127.0.0.1:6379/0/rack:session'

      def initialize(app, options = {})
        super

        @mutex = Mutex.new
        @pool = ::Redis::Store::Factory.create @default_options[:redis_server]
      end

      def generate_unique_sid(session)
        loop do
          sid = generate_sid
          break sid if [1, true].include?([*@pool.setnx(sid, session, @default_options)].first)
        end
      end

      def get_session(env, sid)
        if env['rack.session.options'][:skip]
          [generate_sid, {}]
        else
          with_lock(env, [nil, {}]) do
            unless sid and session = @pool.get(sid)
              session = {}
              sid = generate_unique_sid(session)
            end
            [sid, session]
          end
        end
      end

      def set_session(env, session_id, new_session, options)
        with_lock(env, false) do
          @pool.set session_id, new_session, options
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

