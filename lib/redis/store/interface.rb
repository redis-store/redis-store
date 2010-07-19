class Redis
  class Store < self
    module Interface
      def get(key, options = nil)
        super(key)
      end

      def set(key, value, options = nil)
        super(key, value)
      end

      def setnx(key, value, options = nil)
        super(key, value)
      end
    end
  end
end
