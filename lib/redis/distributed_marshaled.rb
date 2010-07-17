class Redis
  class DistributedMarshaled < Distributed
    attr_reader :ring

    def initialize(addresses)
      nodes = addresses.map do |address|
        ::Redis::Store.new address
      end
      @ring = Redis::HashRing.new nodes
    end

    def nodes
      ring.nodes
    end

    def set(key, val, options = nil)
      node_for(key).set(key, val, options)
    end

    def get(key, options = nil)
      node_for(key).get(key, options)
    end

    def setnx(key, value, options = nil)
      node_for(key).setnx(key, value, options)
    end
  end
end
