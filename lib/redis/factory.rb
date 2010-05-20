class Redis
  class Factory
    def self.create(*redis_client_options)
      redis_client_options = redis_client_options.flatten.compact.inject([]) do |result, address|
        result << convert_to_redis_client_options(address)
        result
      end
      if redis_client_options.size > 1
        DistributedMarshaled.new redis_client_options
      else
        MarshaledClient.new redis_client_options.first || {}
      end
    end

    def self.convert_to_redis_client_options(address_or_options)
      return address_or_options if address_or_options.is_a?(Hash)
      host, port = address_or_options.split /\:/
      port, db   = port.split /\// if port
      options = {}
      options[:host] = host if host
      options[:port] = port if port
      options[:db]  = db.to_i if db
      options
    end
  end
end
