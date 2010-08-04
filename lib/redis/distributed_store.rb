class Redis
  class DistributedStore < Distributed
    attr_reader :ring

    def initialize(addresses, options = { })
      nodes = addresses.map do |address|
        ::Redis::Store.new address
      end
      _extend_namespace options
      @ring = Redis::HashRing.new nodes
    end

    def nodes
      ring.nodes
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
  end
end
