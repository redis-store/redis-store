# class Redis
#   def set(key, val, expiry=nil)#:nodoc: Foreword compatibility with Redis 0.0.3+
#     write("SET #{key} #{val.to_s.size}\r\n#{val}\r\n")
#     s = get_response == OK
#     return expire(key, expiry) if s && expiry
#     s
#   end
# 
#   def expire(key, expiry=nil)#:nodoc: Foreword compatibility with Redis 0.0.3+
#     write("EXPIRE #{key} #{expiry}\r\n")
#     get_response == 1
#   end
# end
