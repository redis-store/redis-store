class MarshaledRedis < Redis
  def set(key, val, options = {})
    val = Marshal.dump val unless options[:raw]
    super key, val, options[:expiry]
  end
  
  def get(key, options = {})
    result = super key
    result = Marshal.load result if result && !options[:raw]
    result
  end
end
