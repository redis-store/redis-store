require 'redis/store/strategy/json'
require 'redis/store/strategy/json_session'
require 'redis/store/strategy/marshal'
require 'redis/store/strategy/yaml'

class Redis
  class Store < self
    module Strategy
      def set(key, value, options = nil)
        dump(value, options) { |value| super encode(key), encode(value), options }
      end

      def setnx(key, value, options = nil)
        dump(value, options) { |value| super encode(key), encode(value), options }
      end

      def setex(key, expiry, value, options = nil)
        dump(value, options) { |value| super encode(key), expiry, encode(value), options }
      end

      def get(key, options = nil)
        load super(key), options
      end

      def mget(*keys)
        options = keys.flatten.pop if keys.flatten.last.is_a?(Hash)
        super(*keys).map do |result|
          load result, options
        end
      end

      private
        def dump(val, options)
          yield dump?(options) ? _dump(val) : val
        end

        def load(val, options)
          load?(val, options) ? _load(val) : val
        end

        def dump?(options)
          !(options && options[:raw])
        end

        def load?(result, options)
          result && result.size > 0 && dump?(options)
        end

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
