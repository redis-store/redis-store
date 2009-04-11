class MarshaledRedis < Redis
  def set(key, val, expiry = nil)
    val = Marshal.dump val
    super
  end
  
  def get(key)
    result = super
    Marshal.load result if result
  end
end
