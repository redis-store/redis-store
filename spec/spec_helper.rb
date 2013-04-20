$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "/../lib")))
ARGV << "-b"
require "rubygems"
require "bundler"
Bundler.setup
require "ostruct"
require "spec"
require "spec/autorun"
require "redis"
require "i18n"
require "rack/cache"
require "rack/cache/metastore"
require "rack/cache/entitystore"
require "redis-store"
require "active_support"
begin
  require "action_controller/session/abstract_store" # Rails 2.3.x
rescue LoadError
  require "action_dispatch/middleware/session/abstract_store" # Rails 3.x
  module ::Rails
    module VERSION
      MAJOR = 3
    end
  end
end
require "active_support/cache/redis_store"
require "action_controller/session/redis_session_store"
require "cache/sinatra/redis_store"

$DEBUG = ENV["DEBUG"] === "true"

# http://mentalized.net/journal/2010/04/02/suppress_warnings_from_ruby/
module Kernel
  def suppress_warnings
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    return result
  end
end

# For faking rails flash objects retrieved from session
module FakeActionDispatch
  class Flash
    class FlashHash < Hash
    end
  end
end
