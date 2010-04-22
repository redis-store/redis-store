class DistributedMarshaledRedis < DistRedis
  def initialize(addresses)
    nodes = addresses.map do |address|
      MarshaledRedis.new address
    end
    @ring = Redis::HashRing.new nodes
  end

  alias_method :flush_db, :delete_cloud!
end
