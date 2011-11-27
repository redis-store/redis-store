require 'test_helper'

describe "Redis::DistributedStore" do
  def setup
    @dmr = Redis::DistributedStore.new [
      {:host => "localhost", :port => "16380", :db => 0},
      {:host => "localhost", :port => "16381", :db => 0}
    ]
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @dmr.set "rabbit", @rabbit
  end

  def teardown
    @dmr.ring.nodes.each { |server| server.flushdb }
  end

  it "accepts connection params" do
    dmr = Redis::DistributedStore.new [ :host => "localhost", :port => "16380", :db => "1" ]
    dmr.ring.nodes.size == 1
    mr = dmr.ring.nodes.first
    mr.to_s.must_equal("Redis Client connected to localhost:16380 against DB 1")
  end

  it "forces reconnection" do
    @dmr.nodes.each do |node|
      node.expects(:reconnect)
    end

    @dmr.reconnect
  end

  it "sets an object" do
    @dmr.set "rabbit", @white_rabbit
    @dmr.get("rabbit").must_equal(@white_rabbit)
  end

  it "gets an object" do
    @dmr.get("rabbit").must_equal(@rabbit)
  end

  describe "namespace" do
    it "uses namespaced key" do
      @dmr = Redis::DistributedStore.new [
        {:host => "localhost", :port => "16380", :db => 0},
        {:host => "localhost", :port => "16381", :db => 0}
      ], :namespace => "theplaylist"

      @dmr.expects(:node_for).with("theplaylist:rabbit").returns(@dmr.nodes.first)
      @dmr.get "rabbit"
    end
  end
end
