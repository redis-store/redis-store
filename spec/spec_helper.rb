$: << File.join(File.dirname(__FILE__), "/../lib")
require "rubygems"
require "ostruct"
require "spec"
require "redis"
require "merb"
require "redis-rails"
require "activesupport"
require "cache/rails/redis_store"
