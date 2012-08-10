require 'json'

class Redis
  class Store < self
    module Strategy
      module Json
        private
          SERIALIZABLE = [String, TrueClass, FalseClass, NilClass, Numeric, Date, Time].freeze
          MARSHAL_INDICATORS = ["\x04", "\004", "\u0004"].freeze
          
          def _dump(object)
            object = _marshal(object)
            object.to_json
          end
          
          def _load(string)
            object = JSON.parse(string, :symbolize_names => true)
            _unmarshal(object)
          end
          
          def _marshal(object)
            case object
            when Hash
              object.each { |k,v| object[k] = _marshal(v) }
            when Array
              object.each_with_index { |v, i| object[i] = _marshal(v) }
            when *SERIALIZABLE
              object
            else
              ::Marshal.dump(object)
            end
          end
          
          def _unmarshal(object)
            case object
            when Hash
              object.each { |k,v| object[k] = _unmarshal(v) }
            when Array
              object.each_with_index { |v, i| object[i] = _unmarshal(v) }
            when String
              object.start_with?(MARSHAL_INDICATORS) ? ::Marshal.load(object) : object
            else
              object
            end
          end
      end
    end
  end
end
