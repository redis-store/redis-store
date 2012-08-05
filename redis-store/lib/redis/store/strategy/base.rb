class Redis
  class Store < self
    module Strategy
      class Base
        def self.dump(val, options = {})
          result = dump?(options) ? _dump(val) : val
          yield result if block_given?
          result
        end

        def self.load(val, options = {})
          load?(val, options) ? _load(val) : val
        end

        private
          def self._dump(val, options)
            raise "_dump must be implemented by the inheriting class"
          end

          def self._load(val, options)
            raise "_load must be implemented by the inheriting class"
          end

          def self.dump?(options)
            !(options && options[:raw])
          end

          def self.load?(result, options)
            result && result.size > 0 && dump?(options)
          end
      end
    end
  end
end
