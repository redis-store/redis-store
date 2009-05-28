require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "RedisFactory" do
  it "should instantiate a MarshaledRedis store" do
    store = RedisFactory.create
    store.should be_kind_of(MarshaledRedis)
    store.host.should == "127.0.0.1"
    store.port.should == 6379
    store.db.should == 0
  end

  it "should allow to specify host" do
    store = RedisFactory.create "localhost"
    store.host.should == "localhost"
  end

  it "should allow to specify port" do
    store = RedisFactory.create "localhost:6380"
    store.host.should == "localhost"
    store.port.should == 6380
  end

  it "should allow to specify db" do
    store = RedisFactory.create "localhost:6380/13"
    store.host.should == "localhost"
    store.port.should == 6380
    store.db.should == 13
  end

  it "should instantiate a DistributedMarshaledRedis store" do
    store = RedisFactory.create "localhost:6379", "localhost:6380"
    store.should be_kind_of(DistributedMarshaledRedis)
  end
end
