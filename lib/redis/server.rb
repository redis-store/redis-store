class Server
  def socket
    return @sock if socket_active?

    @sock.close rescue nil # TODO should we call #close instead?
    @sock = nil

    # If the host was dead, don't retry for a while.
    return if @retry and @retry > Time.now

    # Attempt to connect if not already connected.
    begin
      @sock = connect_to(@host, @port, @timeout)
      @sock.setsockopt Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1
      @retry  = nil
      @status = 'CONNECTED'
    rescue Errno::EPIPE, Errno::ECONNREFUSED => e
      puts "Socket died... socket: #{@sock.inspect}\n" if $debug
      @sock.close
      retry
    rescue SocketError, SystemCallError, IOError => err
      puts "Unable to open socket: #{err.class.name}, #{err.message}" if $debug
      mark_dead err
    end
    @sock
  end

  private
    def socket_active?
      @sock and not @sock.closed? and @sock.stat.readable?
    end
end
