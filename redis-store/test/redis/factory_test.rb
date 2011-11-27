require 'test_helper'

describe "Redis::Factory" do
  describe ".create" do
    describe "when not given any arguments" do
      it "instantiates Redis::Store" do
        store = Redis::Factory.create
        store.must_be_kind_of(Redis::Store)
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0")
      end
    end

    describe "when given a Hash" do
      it "uses specified host" do
        store = Redis::Factory.create :host => "localhost"
        store.to_s.must_equal("Redis Client connected to localhost:6379 against DB 0")
      end

      it "uses specified port" do
        store = Redis::Factory.create :host => "localhost", :port => 6380
        store.to_s.must_equal("Redis Client connected to localhost:6380 against DB 0")
      end

      it "uses specified db" do
        store = Redis::Factory.create :host => "localhost", :port => 6380, :db => 13
        store.to_s.must_equal("Redis Client connected to localhost:6380 against DB 13")
      end

      it "uses specified namespace" do
        store = Redis::Factory.create :namespace => "theplaylist"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist")
      end

      it "uses specified key_prefix as namespace" do
        store = Redis::Factory.create :key_prefix => "theplaylist"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist")
      end

      it "uses specified password" do
        store = Redis::Factory.create :password => "secret"
        store.instance_variable_get(:@client).password.must_equal("secret")
      end

      it "allows/disable marshalling" do
        store = Redis::Factory.create :marshalling => false
        store.instance_variable_get(:@marshalling).must_equal(false)
      end

      it "should instantiate a Redis::DistributedStore store" do
        store = Redis::Factory.create(
          {:host => "localhost", :port => 16379},
          {:host => "localhost", :port => 16380}
        )
        store.must_be_kind_of(Redis::DistributedStore)
        store.nodes.map {|node| node.to_s }.must_equal([
          "Redis Client connected to localhost:16379 against DB 0",
          "Redis Client connected to localhost:16380 against DB 0",
        ])
      end
    end

    describe "when given a String" do
      it "uses specified host" do
        store = Redis::Factory.create "redis://127.0.0.1"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0")
      end

      it "uses specified port" do
        store = Redis::Factory.create "redis://127.0.0.1:6380"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6380 against DB 0")
      end

      it "uses specified db" do
        store = Redis::Factory.create "redis://127.0.0.1:6380/13"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6380 against DB 13")
      end

      it "uses specified namespace" do
        store = Redis::Factory.create "redis://127.0.0.1:6379/0/theplaylist"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist")
      end

      it "uses specified password" do
        store = Redis::Factory.create "redis://:secret@127.0.0.1:16379/0/theplaylist"
        store.instance_variable_get(:@client).password.must_equal("secret")
      end

      # TODO why we need this?
      it "allows to specify password without scheme" do
        suppress_warnings do
          store = Redis::Factory.create ":secret@127.0.0.1:16379/0/theplaylist"
          store.instance_variable_get(:@client).password.must_equal("secret")
        end
      end

      it "instantiates Redis::DistributedStore" do
        store = Redis::Factory.create "redis://127.0.0.1:16379", "redis://127.0.0.1:16380"
        store.must_be_kind_of(Redis::DistributedStore)
        store.nodes.map {|node| node.to_s }.must_equal([
          "Redis Client connected to 127.0.0.1:16379 against DB 0",
          "Redis Client connected to 127.0.0.1:16380 against DB 0",
        ])
      end
    end
  end
end
