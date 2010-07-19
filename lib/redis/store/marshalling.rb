class Redis
  class Store < self
    module Marshalling
      def set(key, value, options = nil)
        _marshal(value, options) { |value| super key, value, options }
      end

      def setnx(key, value, options = nil)
        _marshal(value, options) { |value| super key, value, options }
      end

      def get(key, options = nil)
        _unmarshal super(key), options
      end

      def mget(*keys)
        options = keys.flatten.pop if keys.flatten.last.is_a?(Hash)
        super(*keys).map do |result|
          _unmarshal result, options
        end
      end

      private
        def _marshal(val, options)
          yield marshal?(options) ? val : Marshal.dump(val)
        end

        def _unmarshal(val, options)
          unmarshal?(val, options) ? Marshal.load(val) : val
        end

        def marshal?(options)
          options && options[:raw]
        end

        def unmarshal?(result, options)
          result && result.size > 0 && !marshal?(options)
        end
    end
  end
end
