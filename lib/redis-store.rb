require "redis"
require "redis/distributed"
require "redis/factory"
require "redis/store/interface"
require "redis/store/ttl"
require "redis/store/namespace"
require "redis/store/strategy"
require "redis/store/version"
require "redis/store"
require "redis/distributed_store"

# Cache store
if defined?(Sinatra)
  require "cache/sinatra/redis_store"
elsif defined?(ActiveSupport)
  require "active_support/cache/redis_store"
end

# Rack::Session
if defined?(Rack::Session)
  require "rack/session/abstract/id"
  require "rack/session/redis"
end

if defined?(Rails)
  require "action_controller/session/redis_session_store"
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
