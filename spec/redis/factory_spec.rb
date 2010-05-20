require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "Redis::Factory" do
  describe ".create" do
    context "when not given any arguments" do
      it "should instantiate a Redis::MarshaledClient store" do
        store = Redis::Factory.create
        store.should be_kind_of(Redis::MarshaledClient)
        store.to_s.should == "Redis Client connected to 127.0.0.1:6379 against DB 0"
      end
    end

    context "when given a Hash" do
      it "should allow to specify host" do
        store = Redis::Factory.create :host => "localhost"
        store.to_s.should == "Redis Client connected to localhost:6379 against DB 0"
      end

      it "should allow to specify port" do
        store = Redis::Factory.create :host => "localhost", :port => 6380
        store.to_s.should == "Redis Client connected to localhost:6380 against DB 0"
      end

      it "should allow to specify db" do
        store = Redis::Factory.create :host => "localhost", :port => 6380, :db => 13
        store.to_s.should == "Redis Client connected to localhost:6380 against DB 13"
      end

      it "should instantiate a Redis::DistributedMarshaled store" do
        store = Redis::Factory.create(
          {:host => "localhost", :port => 6379},
          {:host => "localhost", :port => 6380}
        )
        store.should be_kind_of(Redis::DistributedMarshaled)
        store.nodes.map {|node| node.to_s}.should == [
          "Redis Client connected to localhost:6379 against DB 0",
          "Redis Client connected to localhost:6380 against DB 0",
        ]
      end
    end

    context "when given a String" do
      it "should allow to specify host" do
        store = Redis::Factory.create "localhost"
        store.to_s.should == "Redis Client connected to localhost:6379 against DB 0"
      end

      it "should allow to specify port" do
        store = Redis::Factory.create "localhost:6380"
        store.to_s.should == "Redis Client connected to localhost:6380 against DB 0"
      end

      it "should allow to specify db" do
        store = Redis::Factory.create "localhost:6380/13"
        store.to_s.should == "Redis Client connected to localhost:6380 against DB 13"
      end

      it "should instantiate a Redis::DistributedMarshaled store" do
        store = Redis::Factory.create "localhost:6379", "localhost:6380"
        store.should be_kind_of(Redis::DistributedMarshaled)
        store.nodes.map {|node| node.to_s}.should == [
          "Redis Client connected to localhost:6379 against DB 0",
          "Redis Client connected to localhost:6380 against DB 0",
        ]
      end
    end
  end
end
