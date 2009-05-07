class Server
  def initialize_with_connection_pool(host, port = DEFAULT_PORT, timeout = 1, size = 5)
    initialize_without_connection_pool(host, port)

    @size = size
    @timeout = timeout
    @reserved_sockets = {}

    @mutex = Monitor.new
    @queue = @mutex.new_cond

    @sockets = []
    @checked_out = []
  end

  alias_method :initialize_without_connection_pool, :initialize
  alias_method :initialize, :initialize_with_connection_pool

  alias_method :new_socket, :socket
  def socket
    if socket = @reserved_sockets[current_connection_id]
      socket
    else
      @reserved_sockets[current_connection_id] = checkout
    end
  end

  protected
    def checkout
      @mutex.synchronize do
        loop do
          socket = if @checked_out.size < @sockets.size
                   checkout_existing_socket
                 elsif @sockets.size < @size
                   checkout_new_socket
                 end
          return socket if socket
          # No sockets available; wait for one
          if @queue.wait(@timeout)
            next
          else
            # try looting dead threads
            clear_stale_cached_sockets!
            if @size == @checked_out.size
              raise RedisError, "could not obtain a socket connection#{" within #{@timeout} seconds" if @timeout}.  The max pool size is currently #{@size}; consider increasing it."
            end
          end
        end
      end
    end

    def checkin(socket)
      @mutex.synchronize do
        @checked_out.delete socket
        @queue.signal
      end
    end

    def checkout_new_socket
      s = new_socket
      @sockets << s
      checkout_and_verify(s)
    end

    def checkout_existing_socket
      s = (@sockets - @checked_out).first
      checkout_and_verify(s)
    end

    def clear_stale_cached_sockets!
      remove_stale_cached_threads!(@reserved_sockets) do |name, socket|
        checkin socket
      end
    end

    def remove_stale_cached_threads!(cache, &block)
      keys = Set.new(cache.keys)

      Thread.list.each do |thread|
        keys.delete(thread.object_id) if thread.alive?
      end
      keys.each do |key|
        next unless cache.has_key?(key)
        block.call(key, cache[key])
        cache.delete(key)
      end
    end

  private
    def current_connection_id #:nodoc:
      Thread.current.object_id
    end

    def checkout_and_verify(s)
      s = verify!(s)
      @checked_out << s
      s
    end
    
    def verify!(s)
      reconnect!(s) unless active?(s)
    end

    def reconnect!(s)
      s.close
      connect_to(@host, @port, @timeout)
    end

    def active?(s)
      begin
        s.write("\0")
        Timeout.timeout(0.1){ s.read }
      rescue Exception
        false
      end
    end
end
