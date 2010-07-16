class Redis
  module Namespace
    def marshalled_set(key, val, options = nil)
      namespace(key) { |key| super }
    end

    def marshalled_setnx(key, val, options = nil)
      namespace(key) { |key| super }
    end

    def marshalled_get(key, options = nil)
      namespace(key) { |key| super }
    end

    def exists(key)
      namespace(key) { |key| super }
    end

    def incrby(key, increment)
      namespace(key) { |key| super }
    end

    def decrby(key, increment)
      namespace(key) { |key| super }
    end

    def keys(pattern = "*")
      namespace(pattern) { |pattern| super }
    end

    def del(*keys)
      super *keys.map {|key| interpolate key }
    end

    def mget(*keys)
      super *keys.map {|key| interpolate key }
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
