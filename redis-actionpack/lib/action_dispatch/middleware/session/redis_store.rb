require 'redis-store'
require 'redis-rack'
require 'action_dispatch/middleware/session/abstract_store'

class ActionDispatch::Session::RedisSessionStore < Rack::Session::Redis
  include ActionDispatch::Session::Compatibility
  include ActionDispatch::Session::StaleSessionCheck
end
