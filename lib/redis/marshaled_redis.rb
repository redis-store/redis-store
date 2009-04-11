class MarshaledRedis < Redis
  def set(key, val, options = nil)
    val = Marshal.dump val unless raw?(options)
    super key, val, expires_in(options)
  end
  
  def get(key, options = nil)
    result = super key
    result = Marshal.load result if result && !raw?(options)
    result
  end
  
  private
    def raw?(options)
      options && options[:raw]
    end

    def expires_in(options)
      options[:expires_in] if options
    end
end
