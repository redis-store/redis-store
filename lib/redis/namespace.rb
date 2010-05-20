begin
  require "redis/dist_redis"
rescue LoadError
  require "redis/distributed"
end

unless defined?(Redis::Distributed)
  class Redis::Distributed < Redis::DistRedis; end
end
