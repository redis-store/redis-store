module ActiveSupport
  module Cache
    class RedisStore < Store
      def initialize
        @data = MarshaledRedis.new
      end

      def write(key, value, options = {})
        super
        @data.set key, value, options
      end

      def read(key, options = {})
        super
        @data.get key, options
      end

      def delete(key, options = nil)
        super
        @data.delete key
      end

      def exist?(key, options = nil)
        super
        @data.key? key
      end

      # Increment a key in the store.
      #
      # If the key doesn't exist it will be initialized on 0.
      # If the key exist but it isn't a Fixnum it will be initialized on 0.
      #
      # Example:
      #   We have two objects in cache:
      #     counter # => 23
      #     rabbit  # => #<Rabbit:0x5eee6c>
      #
      #   cache.increment "counter"
      #   cache.read "counter", :raw => true      # => "24"
      #
      #   cache.increment "counter", 6
      #   cache.read "counter", :raw => true      # => "30"
      #
      #   cache.increment "a counter"
      #   cache.read "a counter", :raw => true    # => "1"
      #
      #   cache.increment "rabbit"
      #   cache.read "rabbit", :raw => true       # => "1"
      def increment(key, options = nil)
        log "increment", key, options
        @data.incr key, options
      end

      # Decrement a key in the store
      #
      # If the key doesn't exist it will be initialized on 0.
      # If the key exist but it isn't a Fixnum it will be initialized on 0.
      #
      # Example:
      #   We have two objects in cache:
      #     counter # => 23
      #     rabbit  # => #<Rabbit:0x5eee6c>
      #
      #   cache.decrement "counter"
      #   cache.read "counter", :raw => true      # => "22"
      #
      #   cache.decrement "counter", 2
      #   cache.read "counter", :raw => true      # => "20"
      #
      #   cache.decrement "a counter"
      #   cache.read "a counter", :raw => true    # => "-1"
      #
      #   cache.decrement "rabbit"
      #   cache.read "rabbit", :raw => true       # => "-1"
      def decrement(key, options = nil)
        log "decrement", key, options
        @data.decr key, options
      end

      # Delete objects for matched keys.
      #
      # Example:
      #   cache.delete_matched "rab*"
      def delete_matched(matcher, options = nil)
        super
        @data.keys(matcher).each { |key| @data.delete key }
      end

      # Clear all the data from the store.
      def clear
        log "clear", nil, nil
        @data.flush_db
      end

      def stats
        @data.info
      end
    end
  end
end
