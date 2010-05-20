require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "Redis::DistributedMarshaled" do
  before(:each) do
    @dmr = Redis::DistributedMarshaled.new [
      {:host => "localhost", :port => "6380", :db => 0},
      {:host => "localhost", :port => "6381", :db => 0}
    ]
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @dmr.marshalled_set "rabbit", @rabbit
  end

  after(:all) do
    @dmr.ring.nodes.each { |server| server.flushdb }
  end

  it "should accept connection params" do
    dmr = Redis::DistributedMarshaled.new [ :host => "localhost", :port => "6380", :db => "1" ]
    dmr.ring.should have(1).node
    mr = dmr.ring.nodes.first
    mr.to_s.should == "Redis Client connected to localhost:6380 against DB 1"
  end

  it "should set an object" do
    @dmr.marshalled_set "rabbit", @white_rabbit
    @dmr.marshalled_get("rabbit").should == @white_rabbit
  end

  it "should get an object" do
    @dmr.marshalled_get("rabbit").should == @rabbit
  end
end
