class Redis
  class DistributedMarshaled < Distributed
    attr_reader :ring

    def initialize(addresses)
      nodes = addresses.map do |address|
        MarshaledClient.new address
      end
      @ring = Redis::HashRing.new nodes
    end

    def nodes
      ring.nodes
    end

    def marshalled_set(key, val, options = nil)
      node_for(key).marshalled_set(key, val, options)
    end

    def marshalled_get(key, options = nil)
      node_for(key).marshalled_get(key, options)
    end

    def marshalled_setnx(key, value, options = nil)
      node_for(key).marshalled_setnx(key, value, options)
    end
  end
end
