class Redis
  class Store < self
    module Marshalling
      def set(key, value, options = nil)
        _marshal(value, options) { |value| super encode(key), encode(value), options }
      end

      def setnx(key, value, options = nil)
        _marshal(value, options) { |value| super encode(key), encode(value), options }
      end

      def setex(key, expiry, value, options = nil)
        _marshal(value, options) { |value| super encode(key), expiry, encode(value), options }
      end

      def get(key, options = nil)
        _unmarshal encode(super(encode(key))), options
      end

      def mget(*keys)
        options = keys.flatten.pop if keys.flatten.last.is_a?(Hash)
        super(*keys.map{|key| encode(key)}).map do |result|
          _unmarshal encode(result), options
        end
      end

      private
        def _marshal(val, options)
          yield marshal?(options) ? Marshal.dump(val) : val
        end

        def _unmarshal(val, options)
          unmarshal?(val, options) ? Marshal.load(val) : val
        end

        def marshal?(options)
          !(options && options[:raw])
        end

        def unmarshal?(result, options)
          result && result.size > 0 && marshal?(options)
        end

        if defined?(Encoding)
          def encode(string)
            if string.nil?
              string
            else
              string.to_s.force_encoding(Encoding::BINARY)
            end
          end
        else
          def encode(string)
            string
          end
        end
    end
  end
end
