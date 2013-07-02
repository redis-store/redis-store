require 'redis/distributed'

class Redis
  class DistributedStore < Distributed
    @@timeout = 5
    attr_reader :ring

    def initialize(addresses, options = { })
      nodes = addresses.map do |address|
        ::Redis::Store.new _merge_options(address, options)
      end

      _extend_namespace options
      @ring = Redis::HashRing.new nodes
    end

    def nodes
      ring.nodes
    end

    def reconnect
      nodes.each {|node| node.reconnect }
    end

    def set(key, value, options = nil)
      node_for(key).set(key, value, options)
    end

    def get(key, options = nil)
      node_for(key).get(key, options)
    end

    def setnx(key, value, options = nil)
      node_for(key).setnx(key, value, options)
    end

    private
      def _extend_namespace(options)
        @namespace = options[:namespace]
        extend ::Redis::Store::Namespace if @namespace
      end

      def _merge_options(address, options)
        address.merge({
          :timeout => options[:timeout] || @@timeout, 
          :namespace => options[:namespace]
        })
      end
  end
end
