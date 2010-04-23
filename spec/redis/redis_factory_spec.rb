require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "RedisFactory" do
  describe ".create" do
    context "when not given any arguments" do
      it "should instantiate a MarshaledRedis store" do
        store = RedisFactory.create
        store.should be_kind_of(MarshaledRedis)
        store.to_s.should == "Redis Client connected to 127.0.0.1:6379 against DB 0"
      end
    end

    context "when given a Hash" do
      it "should allow to specify host" do
        store = RedisFactory.create :host => "localhost"
        store.to_s.should == "Redis Client connected to localhost:6379 against DB 0"
      end

      it "should allow to specify port" do
        store = RedisFactory.create :host => "localhost", :port => 6380
        store.to_s.should == "Redis Client connected to localhost:6380 against DB 0"
      end

      it "should allow to specify db" do
        store = RedisFactory.create :host => "localhost", :port => 6380, :db => 13
        store.to_s.should == "Redis Client connected to localhost:6380 against DB 13"
      end

      it "should instantiate a DistributedMarshaledRedis store" do
        store = RedisFactory.create(
          {:host => "localhost", :port => 6379},
          {:host => "localhost", :port => 6380}
        )
        store.should be_kind_of(DistributedMarshaledRedis)
        store.nodes.map {|node| node.to_s}.should == [
          "Redis Client connected to localhost:6379 against DB 0",
          "Redis Client connected to localhost:6380 against DB 0",
        ]
      end
    end

    context "when given a String" do
      it "should allow to specify host" do
        store = RedisFactory.create "localhost"
        store.to_s.should == "Redis Client connected to localhost:6379 against DB 0"
      end

      it "should allow to specify port" do
        store = RedisFactory.create "localhost:6380"
        store.to_s.should == "Redis Client connected to localhost:6380 against DB 0"
      end

      it "should allow to specify db" do
        store = RedisFactory.create "localhost:6380/13"
        store.to_s.should == "Redis Client connected to localhost:6380 against DB 13"
      end

      it "should instantiate a DistributedMarshaledRedis store" do
        store = RedisFactory.create "localhost:6379", "localhost:6380"
        store.should be_kind_of(DistributedMarshaledRedis)
        store.nodes.map {|node| node.to_s}.should == [
          "Redis Client connected to localhost:6379 against DB 0",
          "Redis Client connected to localhost:6380 against DB 0",
        ]
      end
    end
  end
end
