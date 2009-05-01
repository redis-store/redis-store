module Rack
  module Session
    class Redis < Abstract::ID
      attr_reader :mutex, :pool
      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge :redis_server => "localhost:6379"

      def initialize(app, options = {})
        super

        @mutex = Mutex.new
        addresses = extract_addresses(options[:redis_server] || @default_options[:redis_server])
        @pool = if addresses.size > 1
          DistributedMarshaledRedis.new addresses
        else
          MarshaledRedis.new addresses.first || {}
        end
      end

      private
        def extract_addresses(*addresses) # TODO extract in a module or a class
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
end
