class Redis
  class Store < self
    module Adapters
      module Json
        SERIALIZABLE = [String, TrueClass, FalseClass, NilClass, Numeric, Date, Time].freeze
        
        def self.dump(object)
          object = serialize(object)
          object.to_json
        end
        
        def self.load(string)
          string = string.read if string.respond_to?(:read)
          object = JSON.parse(string, :symbolize_names => true)
          unserialize(object)
        end
        
        private
          def self.serialize(object)
            case object
            when Hash
              object.each { |k,v| puts k, v.class; object[k] = serialize(v) }
            when Array
              object.each_with_index { |v, i| object[i] = serialize(v) }
            when *SERIALIZABLE
              object
            else
              Marshal.dump(object)
            end
          end
          
          def self.unserialize(object)
            case object
            when Hash
              object.each { |k,v| object[k] = unserialize(v) }
            when Array
              object.each_with_index { |v, i| object[i] = unserialize(v) }
            when String
              object.start_with?("\004") ? Marshal.load(object) : object
            else
              object
            end
          end
      end
    end
  end
end
