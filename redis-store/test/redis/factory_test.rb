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

      it "allows json strategy option" do
        store = Redis::Factory.create :strategy => :json
        store.must_be_kind_of(Redis::Store::Strategy::Json)
      end

      it "allows marshal strategy option" do
        store = Redis::Factory.create :strategy => :marshal
        store.must_be_kind_of(Redis::Store::Strategy::Marshal)
      end

      it "allows yaml strategy option" do
        store = Redis::Factory.create :strategy => :yaml
        store.must_be_kind_of(Redis::Store::Strategy::Yaml)
      end

      it "allows false strategy option" do
        store = Redis::Factory.create :strategy => false
        store.wont_be_kind_of(Redis::Store::Strategy::Json)
        store.wont_be_kind_of(Redis::Store::Strategy::Marshal)
        store.wont_be_kind_of(Redis::Store::Strategy::Yaml)
      end

      it "defaults to marshal strategy" do
        store = Redis::Factory.create
        store.must_be_kind_of(Redis::Store::Strategy::Marshal)
      end

      it "should instantiate a Redis::DistributedStore store" do
        store = Redis::Factory.create(
          {:host => "localhost", :port => 6379},
          {:host => "localhost", :port => 6380}
        )
        store.must_be_kind_of(Redis::DistributedStore)
        store.nodes.map {|node| node.to_s }.must_equal([
          "Redis Client connected to localhost:6379 against DB 0",
          "Redis Client connected to localhost:6380 against DB 0",
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
        store = Redis::Factory.create "redis://:secret@127.0.0.1:6379/0/theplaylist"
        store.instance_variable_get(:@client).password.must_equal("secret")
      end

      it "instantiates Redis::DistributedStore" do
        store = Redis::Factory.create "redis://127.0.0.1:6379", "redis://127.0.0.1:6380"
        store.must_be_kind_of(Redis::DistributedStore)
        store.nodes.map {|node| node.to_s }.must_equal([
          "Redis Client connected to 127.0.0.1:6379 against DB 0",
          "Redis Client connected to 127.0.0.1:6380 against DB 0",
        ])
      end
    end
  end
end
