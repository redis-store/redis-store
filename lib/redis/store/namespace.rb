class Redis
  class Store < self
    module Namespace
      def set(key, val, options = nil)
        namespace(key) { |key| super(key, val, options) }
      end

      def setnx(key, val, options = nil)
        namespace(key) { |key| super(key, val, options) }
      end

      def get(key, options = nil)
        namespace(key) { |key| super(key, options) }
      end

      def exists(key)
        namespace(key) { |key| super(key) }
      end

      def incrby(key, increment)
        namespace(key) { |key| super(key, increment) }
      end

      def decrby(key, increment)
        namespace(key) { |key| super(key, increment) }
      end

      def keys(pattern = "*")
        namespace(pattern) { |pattern| super(pattern) }
      end

      def del(*keys)
        super *keys.map {|key| interpolate(key) }
      end

      def mget(*keys)
        super *keys.map {|key| interpolate(key) }
      end

      def to_s
        "#{super} with namespace #{@namespace}"
      end

      private
        def namespace(key)
          yield interpolate(key)
        end

        def interpolate(key)
          key.match(%r{^#{@namespace}\:}) ? key : "#{@namespace}:#{key}"
        end
    end
  end
end
