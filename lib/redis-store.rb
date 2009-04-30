require "redis"
require "dist_redis"
require "redis/marshaled_redis"
require "redis/distributed_marshaled_redis"

if defined?(Merb)
  require "cache/merb/redis_store"
else # rails or ruby application
  require "activesupport"
  require "cache/rails/redis_store"
end
