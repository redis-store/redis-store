$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "/../lib")))
ARGV << "-b"
require "rubygems"
require "bundler"
Bundler.setup

#require "vendor/gems/environment"
require "ostruct"
require "spec"
require "spec/autorun"
require "redis"
require "merb"
require "rack/cache"
require "rack/cache/metastore"
require "rack/cache/entitystore"
require "redis-store"
require "active_support"
require "action_controller/session/abstract_store"
require "cache/rails/redis_store"
require "rack/session/rails"
require "cache/sinatra/redis_store"

$DEBUG = ENV["DEBUG"] === "true"
