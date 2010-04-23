class RedisFactory
  class << self
    def create(*redis_client_options)
      redis_client_options = extract_redis_client_options_set(redis_client_options)
      if redis_client_options.size > 1
        DistributedMarshaledRedis.new redis_client_options
      else
        MarshaledRedis.new redis_client_options.first || {}
      end
    end

    private
    def extract_redis_client_options_set(addresses)
      addresses = addresses.flatten.compact
      addresses.inject([]) do |result, address|
        result << extract_single_redis_client_options(address)
        result
      end
    end

    def extract_single_redis_client_options(address_or_options)
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
