$: << File.join(File.dirname(__FILE__), "/../lib")
require "vendor/gems/environment"
require "ostruct"
require "spec"
require "redis"
#require "merb"
require "rack/cache"
require "rack/cache/metastore"
require "rack/cache/entitystore"
require "redis-store"
require "activesupport"
require "cache/rails/redis_store"
require "cache/sinatra/redis_store"

class Redis; attr_reader :host, :port, :db end
$DEBUG = ENV["DEBUG"] === "true"

# courtesy of http://github.com/ezmobius/redis-rb team
require "tasks/redis.tasks.rb"
def start_detached_redis
  result = RedisRunner.start_detached
  raise("Could not start redis-server, aborting") unless result
end

def stop_detached_redis
  begin
    @r.quit
  ensure
    RedisRunner.stop
  end
end
