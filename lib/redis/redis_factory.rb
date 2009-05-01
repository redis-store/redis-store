class RedisFactory
  class << self
    def create(*addresses)
      addresses = extract_addresses(addresses)
      if addresses.size > 1
        DistributedMarshaledRedis.new addresses
      else
        MarshaledRedis.new addresses.first || {}
      end
    end
    
    private
      def extract_addresses(addresses)
        addresses = addresses.flatten.compact
        addresses.inject([]) do |result, address|
          host, port = address.split /\:/
          port, db   = port.split /\// if port
          address = {}
          address[:host] = host if host
          address[:port] = port if port
          address[:db]  = db.to_i if db
          result << address
          result
        end
      end
  end
end
