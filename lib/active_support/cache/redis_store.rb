require "redis-store"

module ::RedisStore
  module Cache
    module Rails2
      # Instantiate the store.
      #
      # Example:
      #   RedisStore.new
      #     # => host: localhost,   port: 6379,  db: 0
      #
      #   RedisStore.new "example.com"
      #     # => host: example.com, port: 6379,  db: 0
      #
      #   RedisStore.new "example.com:23682"
      #     # => host: example.com, port: 23682, db: 0
      #
      #   RedisStore.new "example.com:23682/1"
      #     # => host: example.com, port: 23682, db: 1
      #
      #   RedisStore.new "example.com:23682/1/theplaylist"
      #     # => host: example.com, port: 23682, db: 1, namespace: theplaylist
      #
      #   RedisStore.new "localhost:6379/0", "localhost:6380/0"
      #     # => instantiate a cluster
      def initialize(*addresses)
        @data = ::Redis::Factory.create(addresses)
      end

      def write(key, value, options = nil)
        super
        method = options && options[:unless_exist] ? :setnx : :set
        @data.send method, key, value, options
      end

      def read(key, options = nil)
        super
        @data.get key, options
      end

      def delete(key, options = nil)
        super
        @data.del key
      end

      def exist?(key, options = nil)
        super
        @data.exists key
      end

      # Delete objects for matched keys.
      #
      # Example:
      #   cache.del_matched "rab*"
      def delete_matched(matcher, options = nil)
        instrument(:delete_matched, matcher, options) do
          @data.keys(matcher).each { |key| @data.del key }
        end
      end

      private
        def instrument(operation, key, options = nil)
          log(operation.to_s, key, options)
          yield
        end
    end

    module Rails3
      # Instantiate the store.
      #
      # Example:
      #   RedisStore.new
      #     # => host: localhost,   port: 6379,  db: 0
      #
      #   RedisStore.new "example.com"
      #     # => host: example.com, port: 6379,  db: 0
      #
      #   RedisStore.new "example.com:23682"
      #     # => host: example.com, port: 23682, db: 0
      #
      #   RedisStore.new "example.com:23682/1"
      #     # => host: example.com, port: 23682, db: 1
      #
      #   RedisStore.new "example.com:23682/1/theplaylist"
      #     # => host: example.com, port: 23682, db: 1, namespace: theplaylist
      #
      #   RedisStore.new "localhost:6379/0", "localhost:6380/0"
      #     # => instantiate a cluster
      def initialize(*addresses)
        @data = ::Redis::Factory.create(addresses)
        super(addresses.extract_options!)
      end

      # Delete objects for matched keys.
      #
      # Example:
      #   cache.del_matched "rab*"
      def delete_matched(matcher, options = nil)
        options = merged_options(options)
        instrument(:delete_matched, matcher.inspect) do
          matcher = key_matcher(matcher, options)
          @data.keys(matcher).each { |key| delete_entry(key, options) }
        end
      end

      protected
        def write_entry(key, entry, options)
          method = options && options[:unless_exist] ? :setnx : :set
          @data.send method, key, entry, options
        end

        def read_entry(key, options)
          entry = @data.get key, options
          if entry
            entry.is_a?(ActiveSupport::Cache::Entry) ? entry : ActiveSupport::Cache::Entry.new(entry)
          end
        end

        def delete_entry(key, options)
          @data.del key
        end

        # Add the namespace defined in the options to a pattern designed to match keys.
        #
        # This implementation is __different__ than ActiveSupport:
        # __it doesn't accept Regular expressions__, because the Redis matcher is designed
        # only for strings with wildcards.
        def key_matcher(pattern, options)
          prefix = options[:namespace].is_a?(Proc) ? options[:namespace].call : options[:namespace]
          if prefix
            raise "Regexps aren't supported, please use string with wildcards." if pattern.is_a?(Regexp)
            "#{prefix}:#{pattern}"
          else
            pattern
          end
        end
    end

    module Store
      include ::Redis::Store.rails3? ? Rails3 : Rails2
    end
  end
end

module ActiveSupport
  module Cache
    class RedisStore < Store
      include ::RedisStore::Cache::Store

      # Reads multiple keys from the cache using a single call to the
      # servers for all keys. Options can be passed in the last argument.
      #
      # Example:
      #   cache.read_multi "rabbit", "white-rabbit"
      #   cache.read_multi "rabbit", "white-rabbit", :raw => true
      def read_multi(*names)
        @data.mget *names
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
        instrument(:increment, key, :amount => amount) do
          @data.incrby key, amount
        end
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
        instrument(:decrement, key, :amount => amount) do
          @data.decrby key, amount
        end
      end

      # Clear all the data from the store.
      def clear
        instrument(:clear, nil, nil) do
          @data.flushdb
        end
      end

      def stats
        @data.info
      end
    end
  end
end
