require 'uri'

class Redis
  class Store < self
    class Factory
      def self.create(*options)
        new(options).create
      end

      def initialize(*options)
        @options = extract_options(options)
      end

      def create
        if @options.size > 1
          ::Redis::DistributedStore.new @options
        else
          ::Redis::Store.new @options.first || {}
        end
      end

      def self.resolve(uri) #:api: private
        if uri.is_a?(Hash)
          options = uri.dup
          options[:namespace] ||= options.delete(:key_prefix) # RailsSessionStore
          options
        else
          uri = URI.parse(uri)
          _, db, namespace = if uri.path
                               uri.path.split(/\//)
                             end

          options = {
            :host     => uri.host,
            :port     => uri.port || 6379,
            :password => uri.password
          }

          options[:db]        = db.to_i   if db
          options[:namespace] = namespace if namespace

          options
        end
      end

      private
      def extract_options(*options)
        options.flatten.compact.inject([]) do |result, address|
          result << self.class.resolve(address)
          result
        end
      end
    end
  end
end
