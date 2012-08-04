class Redis
  class Store < self
    module Adapters
      module Marshal
        def self.dump(object)
          ::Marshal.dump(object)
        end
        
        def self.load(string)
          ::Marshal.load(string)
        end
      end
    end
  end
end
