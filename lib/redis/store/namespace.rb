class Redis
  class Store < self
    module Namespace
      def set(key, val, options = nil)
        namespace(key) { |key| super(key, val, options) }
      end

      def setex(key, ttl, val, options = nil)
        namespace(key) { |key| super(key, ttl, val, options) }
      end

      def setnx(key, val, options = nil)
        namespace(key) { |key| super(key, val, options) }
      end

      def ttl(key, options = nil)
        namespace(key) { |key| super(key) }
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
        options = keys.pop if keys.last.is_a? Hash
        if keys.any?
          # Marshalling gets extended before Namespace does, so we need to pass options further
          if singleton_class.ancestors.include? Marshalling
            super *keys.map {|key| interpolate(key) }, options
          else
            super *keys.map {|key| interpolate(key) }
          end
        end
      end
      
      def expire(key, ttl)
         namespace(key) { |key| super(key, ttl) }
      end
      
      def ttl(key)
         namespace(key) { |key| super(key) }
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
