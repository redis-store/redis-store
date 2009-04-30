require "redis"
require "dist_redis"
require "redis/marshaled_redis"
require "redis/distributed_marshaled_redis"

# Cache store
if defined?(Sinatra)
  require "cache/sinatra/redis_store"
elsif defined?(Merb)
  # HACK for cyclic dependency: redis-store is required before merb-cache
  module Merb; module Cache; class AbstractStore; end end end
  require "cache/merb/redis_store"
else # rails or ruby application
  require "activesupport"
  require "cache/rails/redis_store"
end

# Rack::Cache
if defined?(Rack::Cache)
  require "rack/cache/redis_metastore"
end
