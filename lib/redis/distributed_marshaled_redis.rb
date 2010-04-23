class DistributedMarshaledRedis < DistRedis
  attr_reader :ring

  def initialize(addresses)
    nodes = addresses.map do |address|
      MarshaledRedis.new address
    end
    @ring = Redis::HashRing.new nodes
  end

  def nodes
    ring.nodes
  end

  alias_method :flushdb, :delete_cloud!
end
