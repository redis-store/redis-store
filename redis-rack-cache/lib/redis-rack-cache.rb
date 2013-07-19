require 'redis-store'
require 'rack/cache'
require 'rack/cache/redis_entitystore'
require 'rack/cache/redis_metastore'
require 'redis-rack-cache/version'

module RedisRackCache
  def self.max_cache_seconds
    @max_cache_seconds ||= 60 * 30
  end

  def self.max_cache_seconds= (val)
    @max_cache_seconds
  end
end
