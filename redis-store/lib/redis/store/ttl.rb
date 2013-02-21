class Redis
  class Store < self
    module Ttl
      def set(key, value, options = nil)
        options = clean_options(options)

        if ttl = expires_in(options)
          setex(key, ttl.to_i, value, :raw => true)
        else
          super(key, value)
        end
      end

      def setnx(key, value, options = nil)
        options = clean_options(options)

        if ttl = expires_in(options)
          setnx_with_expire(key, value, ttl.to_i)
        else
          super(key, value)
        end
      end

      protected
        def setnx_with_expire(key, value, ttl)
          multi do
            setnx(key, value, :raw => true)
            expire(key, ttl)
          end
        end

      private

        # HACK, TODO, options should be clean on arrival
        def clean_options(options)
          options = options[:redis_server] if options && options[:redis_server] && options[:redis_server].is_a?(Hash)
          options
        end

        def expires_in(options)
          if options
            # Rack::Session           Merb                    Rails/Sinatra
            options[:expire_after] || options[:expires_in] || options[:expire_in]
          end
        end
    end
  end
end
