require "redis"
require "redis/distributed"
require "redis/factory"
require "redis/store/interface"
require "redis/store/ttl"
require "redis/store/namespace"
require "redis/store/marshalling"
require "redis/store/version"
require "redis/store"
require "redis/distributed_store"

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

if ::Redis::Store.rails3?
  # ActionDispatch::Session
  require "action_controller/session/redis_session_store"
elsif defined?(ActiveSupport::Cache)
  # Force loading, in case you're using Bundler, without requiring the gem with:
  #   config.gem "redis-store"
  require "active_support/cache/redis_store"
end

# Rack::Cache
if defined?(Rack::Cache)
  require "rack/cache/key"
  require "rack/cache/redis_metastore"
  require "rack/cache/redis_entitystore"
end

if defined?(I18n)
  require "i18n/backend/redis"
end
