require "redis"
require "redis/distributed"
require "redis/factory"
require "redis/marshaled_client"
require "redis/distributed_marshaled"
require "redis_store/version"

module ::RedisStore
  def self.rails3? #:nodoc:
    defined?(::Rails) && ::Rails.version =~ /3\.0\.0/
  end
end

# Cache store
if defined?(Sinatra)
  require "cache/sinatra/redis_store"
elsif defined?(Merb)
  # HACK for cyclic dependency: redis-store is required before merb-cache
  module Merb; module Cache; class AbstractStore; end end end
  require "cache/merb/redis_store"
end

# Rack::Session
if defined?(Rack::Session)
  require "rack/session/abstract/id"
  require "rack/session/redis"
  if defined?(Merb)
    require "rack/session/merb"
  end
end

# Rack::Cache
if defined?(Rack::Cache)
  require "rack/cache/key"
  require "rack/cache/redis_metastore"
  require "rack/cache/redis_entitystore"
end
