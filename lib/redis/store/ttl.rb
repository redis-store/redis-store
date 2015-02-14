class Redis
  class Store < self
    module Ttl
      def set(key, value, options = nil)
        if ttl = expires_in(options)
          setex(key, ttl.to_i, value, :raw => true)
        else
          super(key, value, options)
        end
      end

      def setnx(key, value, options = nil)
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
        def expires_in(options)
          if options
            # Rack::Session           Merb                    Rails/Sinatra
            options[:expire_after] || options[:expires_in] || options[:expire_in]
          end
        end
    end
  end
end
