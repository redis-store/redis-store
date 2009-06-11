$: << File.join(File.dirname(__FILE__), "/../lib")
require "rubygems"
require "ostruct"
require "spec"
require "redis"
require "merb"
require "rack/cache"
require "rack/cache/metastore"
require "rack/cache/entitystore"
require "redis-store"
require "activesupport"
require "cache/rails/redis_store"
require "cache/sinatra/redis_store"

class Redis; attr_reader :host, :port, :db end
$DEBUG = ENV["DEBUG"] === "true"
