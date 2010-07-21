module I18n
  module Backend
    class Redis
      include Base, Flatten
      attr_accessor :store

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
        @store = ::Redis::Factory.create(addresses)
      end

      def translate(locale, key, options = {})
        options[:resolve] ||= false
        super locale, key, options
      end

      def store_translations(locale, data, options = {})
        escape = options.fetch(:escape, true)
        flatten_translations(locale, data, escape, false).each do |key, value|
          case value
          when Proc
            raise "Key-value stores cannot handle procs"
          else
            @store.set "#{locale}.#{key}", value
          end
        end
      end

      def available_locales
        locales = @store.keys.map { |k| k =~ /\./; $` }
        locales.uniq!
        locales.compact!
        locales.map! { |k| k.to_sym }
        locales
      end

      protected
        def lookup(locale, key, scope = [], options = {})
          key = normalize_flat_keys(locale, key, scope, options[:separator])
          @store.get "#{locale}.#{key}"
        end

        def resolve_link(locale, key)
          key
        end
    end
  end
end
