require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "DistributedMarshaledRedis" do
  before(:each) do
    @dmr = DistributedMarshaledRedis.new [
      {:host => "localhost", :port => "6380", :db => 0},
      {:host => "localhost", :port => "6381", :db => 0}
    ]
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @dmr.set "rabbit", @rabbit
  end

  after(:all) do
    @dmr.ring.nodes.each { |server| server.flush_db }
  end

  it "should accept connection params" do
    dmr = DistributedMarshaledRedis.new [ :host => "localhost", :port => "6380", :db => "1" ]
    dmr.ring.should have(1).node
    mr = dmr.ring.nodes.first
    mr.host.should == "localhost"
    mr.port.should == 6380
    mr.db.should == 1
  end

  it "should set an object" do
    @dmr.set "rabbit", @white_rabbit
    @dmr.get("rabbit").should == @white_rabbit
  end

  it "should get an object" do
    @dmr.get("rabbit").should == @rabbit
  end
end
