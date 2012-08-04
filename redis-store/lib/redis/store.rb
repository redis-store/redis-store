require 'redis/store/ttl'
require 'redis/store/interface'
require 'active_support/inflector'

class Redis
  class Store < self
    include Ttl, Interface

    def initialize(options = { })
      super
      _set_adapter        options
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
      def _set_adapter(options)
        adapter = options[:adapter] || :marshal

        @adapter = case adapter
          when Symbol then "Redis::Store::Adapters::#{adapter.to_s.classify}".constantize
          when String then adapter.constantize
          else adapter
        end
      end

      def _extend_marshalling(options)
        @marshalling = !(options[:marshalling] === false) # HACK - TODO delegate to Factory
        extend Marshalling if @marshalling
      end

      def _extend_namespace(options)
        @namespace = options[:namespace]
        extend Namespace if @namespace
      end

      def adapter
        @adapter
      end
  end
end

