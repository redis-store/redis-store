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

    alias_method :flushdb, :delete_cloud! if respond_to?(:delete_cloud!)
  end
end
