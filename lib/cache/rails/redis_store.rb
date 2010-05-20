module ActiveSupport
  module Cache
    class RedisStore < Store
      # Instantiate the store.
      #
      # Example:
      #   RedisStore.new                       # => host: localhost,   port: 6379,  db: 0
      #   RedisStore.new "example.com"         # => host: example.com, port: 6379,  db: 0
      #   RedisStore.new "example.com:23682"   # => host: example.com, port: 23682, db: 0
      #   RedisStore.new "example.com:23682/1" # => host: example.com, port: 23682, db: 1
      #   RedisStore.new "localhost:6379/0", "localhost:6380/0" # => instantiate a cluster
      def initialize(*addresses)
        @data = Redis::Factory.create(addresses)
      end

      def write(key, value, options = nil)
        super
        method = options && options[:unless_exist] ? :marshalled_setnx : :marshalled_set
        @data.send method, key, value, options
      end

      def read(key, options = nil)
        super
        @data.marshalled_get key, options
      end

      def delete(key, options = nil)
        super
        @data.del key
      end

      def exist?(key, options = nil)
        super
        @data.exists key
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
      def increment(key, amount = 1)
        log "increment", key, amount
        @data.incrby key, amount
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
      def decrement(key, amount = 1)
        log "decrement", key, amount
        @data.decrby key, amount
      end

      # Delete objects for matched keys.
      #
      # Example:
      #   cache.del_matched "rab*"
      def delete_matched(matcher, options = nil)
        super
        @data.keys(matcher).each { |key| @data.del key }
      end

      # Clear all the data from the store.
      def clear
        log "clear", nil, nil
        @data.flushdb
      end

      def stats
        @data.info
      end
    end
  end
end
