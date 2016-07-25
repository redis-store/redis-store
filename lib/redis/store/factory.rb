require 'uri'

class Redis
  class Store < self
    class Factory

      DEFAULT_PORT = 6379

      def self.create(*options)
        new(options).create
      end

      def initialize(*options)
        @addresses = []
        @options   = {}
        extract_addresses_and_options(options)
      end

      def create
        if @addresses.empty?
          @addresses << {}
        end
        
        if @addresses.size > 1
          ::Redis::DistributedStore.new @addresses, @options
        else
          ::Redis::Store.new @addresses.first.merge(@options)
        end
      end

      def self.resolve(uri) #:api: private
        if uri.is_a?(Hash)
          extract_host_options_from_hash(uri)
        else
          extract_host_options_from_uri(uri)
        end
      end

      def self.extract_host_options_from_hash(options)
        options = normalize_key_names(options)
        if host_options?(options)
          options
        else
          nil 
        end
      end

      def self.normalize_key_names(options)
        options = options.dup
        if options.key?(:key_prefix) && !options.key?(:namespace)
          options[:namespace] = options.delete(:key_prefix) # RailsSessionStore
        end
        options[:raw] = !options[:marshalling]
        options
      end

      def self.host_options?(options)
        if options.keys.any? {|n| [:host, :db, :port].include?(n) }
          options
        else
          nil # just to be clear
        end
      end

      def self.extract_host_options_from_uri(uri)
        uri = URI.parse(uri)
        _, db, namespace = if uri.path
                             uri.path.split(/\//)
                           end

        options = {
          :host     => uri.hostname,
          :port     => uri.port || DEFAULT_PORT, 
          :password => uri.password
        }

        options[:db]        = db.to_i   if db
        options[:namespace] = namespace if namespace

        options
      end

      private

      def extract_addresses_and_options(*options)
        options.flatten.compact.each do |token| 
          resolved = self.class.resolve(token)
          if resolved
            @addresses << resolved
          else
            @options.merge!(self.class.normalize_key_names(token))
          end
        end
      end

    end
  end
end
