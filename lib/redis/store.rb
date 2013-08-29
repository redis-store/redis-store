require 'redis/store/ttl'
require 'redis/store/interface'

class Redis
  class Store < self
    include Ttl, Interface

    def initialize(options = { })
      super
      _extend_marshalling options
      _extend_namespace   options
    end

    def reconnect
      @client.reconnect
    end

    def to_s
      "Redis Client connected to #{@client.host}:#{@client.port} against DB #{@client.db}"
    end

    private
      def _extend_marshalling(options)
        @marshalling = !(options[:marshalling] === false) # HACK - TODO delegate to Factory
        extend Marshalling if @marshalling
      end

      def _extend_namespace(options)
        @namespace = options[:namespace]
        extend Namespace if @namespace
      end
  end
end

