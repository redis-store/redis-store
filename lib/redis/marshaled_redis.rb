class MarshaledRedis < Redis::Client
  def set(key, val, options = nil)
    if options && expires_in(options)
      set_with_expire key, val, expires_in(options)
    else
      super key, (raw?(options) ? val : Marshal.dump(val) )
    end
  end

  def setnx(key, val, options = nil)
    val = Marshal.dump val unless raw?(options)
    super key, val    
  end

  def get(key, options = nil)
    result = call_command([:get, key])
    result = Marshal.load result if unmarshal?(result, options)
    result
  end
  def multi(&blk)
    yield(self)
  end
  private
    def unmarshal?(result, options)
      result && result.size > 0 && !raw?(options)
    end

    def raw?(options)
      options && options[:raw]
    end

    def expires_in(options)
      if options
        # Rack::Session           Merb                    Rails/Sinatra
        options[:expire_after] || options[:expires_in] || options[:expire_in]
      end
    end
end
