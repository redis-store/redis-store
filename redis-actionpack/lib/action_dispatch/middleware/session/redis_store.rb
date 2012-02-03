require 'redis-store'
require 'redis-rack'
require 'action_dispatch/middleware/session/abstract_store'

module ActionDispatch
  module Session
    class RedisStore < Rack::Session::Redis
      include Compatibility
      include StaleSessionCheck
      def initialize(app, options = {})
        options = options.dup
        options[:redis_server] ||= options[:servers]
        super
      end
    end
  end
end
