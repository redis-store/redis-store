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
        namespace(pattern) { |pattern| super(pattern).map{|key| strip_namespace(key) } }
      end

      def del(*keys)
        super *keys.map {|key| interpolate(key) } if keys.any?
      end

      def mget(*keys)
        super *keys.map {|key| interpolate(key) } if keys.any?
      end

      def to_s
        "#{super} with namespace #{namespace_str}"
      end

      def flushdb
        del *keys
      end

      private
        def namespace(key)
          yield interpolate(key)
        end

        def namespace_str
          @namespace.is_a?(Proc) ? @namespace.call : @namespace
        end

        def interpolate(key)
          key.match(namespace_regexp) ? key : "#{namespace_str}:#{key}"
        end


        def strip_namespace(key)
          key.gsub namespace_regexp, ""
        end

        def namespace_regexp
          @namespace_regexps ||= {}
          @namespace_regexps[namespace_str] ||= %r{^#{namespace_str}\:}
        end
    end
  end
end
