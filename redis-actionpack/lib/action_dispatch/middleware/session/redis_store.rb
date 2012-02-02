require 'redis-store'
require 'redis-rack'
require 'action_dispatch/middleware/session/abstract_store'

module ActionDispatch
  module Session
    class RedisStore < Rack::Session::Redis
      include Compatibility
      include StaleSessionCheck
    end
  end
end
