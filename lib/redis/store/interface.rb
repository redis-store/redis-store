class Redis
  class Store < self
    module Interface
      def get(key, options = nil)
        super(key)
      end

      def set(key, value, options = nil)
        super(key, value, options || {})
      end

      def setnx(key, value, options = nil)
        super(key, value)
      end

      def setex(key, expiry, value, options = nil)
        super(key, expiry, value)
      end
    end
  end
end
