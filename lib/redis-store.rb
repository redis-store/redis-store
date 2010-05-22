require "redis"
require "redis/distributed"
require "redis/factory"
require "redis/marshaled_client"
require "redis/distributed_marshaled"

# Cache store
if defined?(Sinatra)
  require "cache/sinatra/redis_store"
elsif defined?(Merb)
  # HACK for cyclic dependency: redis-store is required before merb-cache
  module Merb; module Cache; class AbstractStore; end end end
  require "cache/merb/redis_store"
elsif defined?(Rails)
  require "cache/rails/redis_store"
end

# Rack::Session
if defined?(Rack::Session)
  require "rack/session/abstract/id"
  require "rack/session/redis"
  if defined?(Merb)
    require "rack/session/merb"
  end
  if defined?(Rails)
    require "rack/session/rails"
  end
end

# Rack::Cache
if defined?(Rack::Cache)
  require "rack/cache/key"
  require "rack/cache/redis_metastore"
  require "rack/cache/redis_entitystore"
end
