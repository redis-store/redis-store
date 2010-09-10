class Redis
  class Store < self
    module Ttl
      def set(key, value, options = nil)
        if ttl = expires_in(options)
          setex(key, ttl, value)
        else
          super(key, value)
        end
      end

      def setnx(key, value, options = nil)
        if ttl = expires_in(options)
          setnx_with_expire(key, value, ttl)
        else
          super(key, value)
        end
      end

      protected
        def setnx_with_expire(key, value, ttl)
          multi do
            setnx(key, value)
            expire(key, expires_in)
          end
        end

      private
        def expires_in(options)
          if options
            # Rack::Session           Merb                    Rails/Sinatra
            options[:expire_after] || options[:expires_in] || options[:expire_in]
          end
        end
    end
  end
end
