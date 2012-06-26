require 'uri'

class Redis
  class Factory
    def self.create(*redis_client_options)
      redis_client_options = redis_client_options.flatten.compact.inject([]) do |result, address|
        result << resolve(address)
        result
      end
      if redis_client_options.size > 1
        ::Redis::DistributedStore.new redis_client_options
      else
        ::Redis::Store.new redis_client_options.first || {}
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
          uri.path.split /\//
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
  end
end
