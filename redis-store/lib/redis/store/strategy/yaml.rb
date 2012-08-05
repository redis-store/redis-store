class Redis
  class Store < self
    module Strategy
      class Yaml < Base
        private
          def self._dump(object)
            YAML.dump(object)
          end
          
          def self._load(string)
            YAML.load(string)
          end
      end
    end
  end
end
