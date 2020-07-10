class Redis
  class Store < self
    module Interface
      def get(key, options = nil)
        super(key)
      end

      REDIS_SET_OPTIONS = %i(ex px nx xx keepttl).freeze
      private_constant :REDIS_SET_OPTIONS

      def set(key, value, options = nil)
        if options && REDIS_SET_OPTIONS.any? { |k| options.key?(k) }
          kwargs = REDIS_SET_OPTIONS.each_with_object({}) do |key, hash|
            hash[key] = options[key] if _option_key?(options, key)
          end

          super(key, value, **kwargs)
        else
          super(key, value)
        end
      end

      def setnx(key, value, options = nil)
        super(key, value)
      end

      def setex(key, expiry, value, options = nil)
        super(key, expiry, value)
      end

      private

        def _option_key?(options, name)
          if options.respond_to? :key?
            options.key? name
          else
            !options[name].nil?
          end
        end
    end
  end
end
