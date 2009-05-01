module Rack
  module Session
    class Redis < Abstract::ID
      attr_reader :mutex, :pool
      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge :redis_server => "localhost:6379"

      def initialize(app, options = {})
        super
        @mutex = Mutex.new
        @pool = RedisFactory.create options[:redis_server] || @default_options[:redis_server]
      end
    end
  end
end
