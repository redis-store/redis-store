module ActiveSupport
  module Cache
    class RedisStore < Store
      def initialize
        @data = MarshaledRedis.new
      end

      def write(key, value, options = {})
        super
        @data.set key, value, options
      end

      def read(key, options = {})
        super
        @data.get key, options
      end
    end
  end
end
