class Redis
  class Store < self
    module Marshalling
      def set(key, value, options = nil)
        _marshal(value, options) { |v| super encode(key), encode(v), options }
      end

      def setnx(key, value, options = nil)
        _marshal(value, options) { |v| super encode(key), encode(v), options }
      end

      def setex(key, expiry, value, options = nil)
        _marshal(value, options) { |v| super encode(key), expiry, encode(v), options }
      end

      def get(key, options = nil)
        _unmarshal super(key), options
      end

      def mget(*keys)
        options = keys.pop if keys.last.is_a?(Hash)
        super(*keys).map do |result|
          _unmarshal result, options
        end
      end

      def mset(*args)
        options = args.pop if args.length.odd?
        updates = []
        args.each_slice(2) do |(key, value)|
          updates << encode(key)
          _marshal(value, options) { |v| updates << encode(v) }
        end
        super(*updates)
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
            key = string.to_s.dup
            key.force_encoding(Encoding::BINARY)
          end
        else
          def encode(string)
            string
          end
        end
    end
  end
end
