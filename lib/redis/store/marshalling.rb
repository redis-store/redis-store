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
          yield marshal?(val, options) ? Marshal.dump(val) : val
        end

        def _unmarshal(val, options)
          unmarshal?(val, options) ? Marshal.load(val) : val
        end

        def marshal?(val, options)
          case val
          when Fixnum
            false
          else
            marshaled?(options)
          end
        end

        def unmarshal?(val, options)
          val && val.size > 0 && marshal?(val, options)
        end

        def marshaled?(options)
          !(options && options[:raw])
        end
    end
  end
end
