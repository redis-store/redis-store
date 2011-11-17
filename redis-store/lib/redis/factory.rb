class Redis
  class Factory
    def self.create(*redis_client_options)
      redis_client_options = redis_client_options.flatten.compact.inject([]) do |result, address|
        result << convert_to_redis_client_options(address)
        result
      end
      if redis_client_options.size > 1
        ::Redis::DistributedStore.new redis_client_options
      else
        ::Redis::Store.new redis_client_options.first || {}
      end
    end

    def self.convert_to_redis_client_options(address_or_options)
      if address_or_options.is_a?(Hash)
        options = address_or_options.dup
        options[:namespace] ||= options.delete(:key_prefix) # RailsSessionStore
        options
      else
        if address_or_options =~ /redis\:\/\//
          require 'uri'
          uri = URI.parse address_or_options
          _, db, namespace = if uri.path
            uri.path.split /\//
          end
        else
          warn "[DEPRECATION] `#{address_or_options}` is deprecated. Please use `redis://#{address_or_options}` instead."
          address_or_options, password = address_or_options.split(/\@/).reverse
          password = password.gsub(/\:/, "") if password
          host, port = address_or_options.split /\:/
          port, db, namespace = port.split /\// if port
        end

        options = {}
        options[:host] = host || uri && uri.host
        options[:port] = port || uri && uri.port
        options[:db]  = db.to_i if db
        options[:namespace] = namespace if namespace
        options[:password]  = password || uri && uri.password
        options
      end
    end
  end
end
