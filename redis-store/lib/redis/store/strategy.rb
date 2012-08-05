require 'redis/store/strategy/base'
require 'redis/store/strategy/json'
require 'redis/store/strategy/marshal'
require 'redis/store/strategy/yaml'

class Redis
  class Store < self
    module Strategy
      def set(key, value, options = nil)
        @strategy.dump(value, options) { |value| super encode(key), encode(value), options }
      end

      def setnx(key, value, options = nil)
        @strategy.dump(value, options) { |value| super encode(key), encode(value), options }
      end

      def setex(key, expiry, value, options = nil)
        @strategy.dump(value, options) { |value| super encode(key), expiry, encode(value), options }
      end

      def get(key, options = nil)
        @strategy.load super(key), options
      end

      def mget(*keys)
        options = keys.flatten.pop if keys.flatten.last.is_a?(Hash)
        super(*keys).map do |result|
          @strategy.load result, options
        end
      end
      
      private
        if defined?(Encoding)
          def encode(string)
            string.to_s.force_encoding(Encoding::BINARY)
          end
        else
          def encode(string)
            string
          end
        end
    end
  end
end
