class Redis
  class Store < self
    module Strategy
      module Yaml
        private
          def _dump(object)
            YAML.dump(object)
          end

          def _load(string)
            YAML.load(string)
          end
      end
    end
  end
end
