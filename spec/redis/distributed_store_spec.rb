require 'spec_helper'

describe "Redis::DistributedStore" do
  before(:each) do
    @dmr = Redis::DistributedStore.new [
      {:host => "localhost", :port => "6380", :db => 0},
      {:host => "localhost", :port => "6381", :db => 0}
    ]
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @dmr.set "rabbit", @rabbit
  end

  after(:all) do
    @dmr.ring.nodes.each { |server| server.flushdb }
  end

  it "should accept connection params" do
    dmr = Redis::DistributedStore.new [ :host => "localhost", :port => "6380", :db => "1" ]
    dmr.ring.nodes.size == 1
    mr = dmr.ring.nodes.first
    mr.to_s.should == "Redis Client connected to localhost:6380 against DB 1"
  end

  it "should set an object" do
    @dmr.set "rabbit", @white_rabbit
    @dmr.get("rabbit").should == @white_rabbit
  end

  it "should get an object" do
    @dmr.get("rabbit").should == @rabbit
  end

  describe "namespace" do
    before :each do
      @dmr = Redis::DistributedStore.new [
        {:host => "localhost", :port => "6380", :db => 0},
        {:host => "localhost", :port => "6381", :db => 0}
      ], :namespace => "theplaylist"
    end

    it "should use namespaced key" do
      @dmr.should_receive(:node_for).with("theplaylist:rabbit").and_return @dmr.nodes.first
      @dmr.get "rabbit"
    end
  end
end
