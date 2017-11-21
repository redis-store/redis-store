require 'redis'
require 'redis/store/factory'
require 'redis/distributed_store'
require 'redis/store/namespace'
require 'redis/store/serialization'
require 'redis/store/version'
require 'redis/store/redis_version'
require 'redis/store/ttl'
require 'redis/store/interface'
require 'redis/store/redis_version'

class Redis
  class Store < self
    include Ttl, Interface, RedisVersion

    def initialize(options = { })
      super

      unless options[:marshalling].nil?
        puts %(
          DEPRECATED: You are passing the :marshalling option, which has been
          replaced with `serializer: Marshal` to support pluggable serialization
          backends. To disable serialization (much like disabling marshalling),
          pass `serializer: nil` in your configuration.

          The :marshalling option will be removed for redis-store 2.0.
        )
      end

      @serializer = options.key?(:serializer) ? options[:serializer] : Marshal

      unless options[:marshalling].nil?
        @serializer = options[:marshalling] ? Marshal : nil
      end

      _extend_marshalling options
      _extend_namespace   options
    end

    def reconnect
      @client.reconnect
    end

    def to_s
      "Redis Client connected to #{location} against DB #{@client.db}"
    end

    def location
      if @client.path
        @client.path
      else
        h = @client.host
        h = "[#{h}]" if h.include?(":")
        "#{h}:#{@client.port}"
      end
    end

    private
      def _extend_marshalling(options)
        extend Serialization unless @serializer.nil?
      end

      def _extend_namespace(options)
        @namespace = options[:namespace]
        extend Namespace
      end
  end
end

