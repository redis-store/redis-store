class Redis
  class Store < self
    module Strategy
      class Marshal < Base
        private
          def self._dump(object)
            ::Marshal.dump(object)
          end
          
          def self._load(string)
            ::Marshal.load(string)
          end
      end
    end
  end
end
