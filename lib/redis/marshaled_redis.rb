class MarshaledRedis < Redis
  def set(key, val, options = nil)
    val = Marshal.dump val unless raw?(options)
    super key, val, expires_in(options)
  end

  def set_unless_exists(key, val, options = nil)
    val = Marshal.dump val unless raw?(options)
    super key, val    
  end

  def get(key, options = nil)
    result = super key
    result = Marshal.load result if unmarshal?(result, options)
    result
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
