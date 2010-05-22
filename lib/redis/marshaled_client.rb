class Redis
  class MarshaledClient < self
    def marshalled_set(key, val, options = nil)
      val = marshal_value(val, options)
      if ttl = expires_in(options)
        setex key, ttl, val
      else
        set key, val
      end
    end

    def marshalled_setnx(key, val, options = nil)
      val = marshal_value(val, options)
      if expires_in = expires_in(options)
        setnx_with_expire key, val, expires_in
      else
        setnx key, val
      end
    end

    def setnx_with_expire(key, value, ttl)
      multi do
        setnx(key, val)
        expire(key, expires_in)
      end
    end

    def marshalled_get(key, options = nil)
      result = @client.call(:get, key)
      result = Marshal.load result if unmarshal?(result, options)
      result
    end

    def to_s
      "Redis Client connected to #{@client.host}:#{@client.port} against DB #{@client.db}"
    end

    private
      def marshal_value(val, options)
        raw?(options) ? val : Marshal.dump(val)
      end

      def unmarshal?(result, options)
        result && result.size > 0 && !raw?(options)
      end

      def raw?(options)
        options && options[:raw]
      end

      def expires_in(options)
        if options
          # Rack::Session           Merb                    Rails/Sinatra
          options[:expire_after] || options[:expires_in] || options[:expire_in]
        end
      end
  end
end
