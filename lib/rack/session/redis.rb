module Rack
  module Session
    class Redis < Abstract::ID
      attr_reader :mutex, :pool
      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge :redis_server => "redis://127.0.0.1:6379/0"

      def initialize(app, options = {})
        super
        @mutex = Mutex.new
        @pool = ::Redis::Factory.create options[:redis_server] || @default_options[:redis_server]
      end

      def generate_sid
        loop do
          sid = super
          break sid unless @pool.get(sid)
        end
      end

      def get_session(env, sid)
        session = @pool.get(sid) if sid
        @mutex.lock if env['rack.multithread']
        unless sid and session
          env['rack.errors'].puts("Session '#{sid.inspect}' not found, initializing...") if $VERBOSE and not sid.nil?
          session = {}
          sid = generate_sid
          ret = @pool.set sid, session
          raise "Session collision on '#{sid.inspect}'" unless ret
        end
        session.instance_variable_set('@old', {}.merge(session))
        return [sid, session]
      rescue Errno::ECONNREFUSED
        warn "#{self} is unable to find server."
        warn $!.inspect
        return [ nil, {} ]
      ensure
        @mutex.unlock if env['rack.multithread']
      end

      def set_session(env, session_id, new_session, options)
        @mutex.lock if env['rack.multithread']
        session = @pool.get(session_id) rescue {}
        if options[:renew] or options[:drop]
          @pool.del session_id
          return false if options[:drop]
          session_id = generate_sid
          @pool.set session_id, 0
        end
        old_session = new_session.instance_variable_get('@old') || {}
        session = merge_sessions session_id, old_session, new_session, session
        @pool.set session_id, session, options
        return session_id
      rescue Errno::ECONNREFUSED
        warn "#{self} is unable to find server."
        warn $!.inspect
        return false
      ensure
        @mutex.unlock if env['rack.multithread']
      end

      private
        def merge_sessions(sid, old, new, cur=nil)
          cur ||= {}
          unless Hash === old and Hash === new
            warn 'Bad old or new sessions provided.'
            return cur
          end

          delete = old.keys - new.keys
          warn "//@#{sid}: dropping #{delete*','}" if $DEBUG and not delete.empty?
          delete.each{|k| cur.delete k }

          update = new.keys.select{|k| new[k] != old[k] }
          warn "//@#{sid}: updating #{update*','}" if $DEBUG and not update.empty?
          update.each{|k| cur[k] = new[k] }

          cur
        end
    end
  end
end
