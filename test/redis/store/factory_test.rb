require 'test_helper'

describe "Redis::Store::Factory" do
  describe ".create" do
    describe "when not given any arguments" do
      it "instantiates Redis::Store" do
        store = Redis::Store::Factory.create
        store.must_be_kind_of(Redis::Store)
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0")
      end
    end

    describe "when given a Hash" do
      it "uses specified host" do
        store = Redis::Store::Factory.create :host => "localhost"
        store.to_s.must_equal("Redis Client connected to localhost:6379 against DB 0")
      end

      it "uses specified port" do
        store = Redis::Store::Factory.create :host => "localhost", :port => 6380
        store.to_s.must_equal("Redis Client connected to localhost:6380 against DB 0")
      end

      it "uses specified db" do
        store = Redis::Store::Factory.create :host => "localhost", :port => 6380, :db => 13
        store.to_s.must_equal("Redis Client connected to localhost:6380 against DB 13")
      end

      it "uses specified namespace" do
        store = Redis::Store::Factory.create :namespace => "theplaylist"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist")
      end

      it "uses specified key_prefix as namespace" do
        store = Redis::Store::Factory.create :key_prefix => "theplaylist"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist")
      end

      it "uses specified password" do
        store = Redis::Store::Factory.create :password => "secret"
        store.instance_variable_get(:@client).password.must_equal("secret")
      end

      it "allows/disable marshalling" do
        store = Redis::Store::Factory.create :marshalling => false
        store.instance_variable_get(:@marshalling).must_equal(false)
        store.instance_variable_get(:@options)[:raw].must_equal(true)
      end

      it "should instantiate a Redis::DistributedStore store" do
        store = Redis::Store::Factory.create(
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
        store = Redis::Store::Factory.create "redis://127.0.0.1"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0")
      end

      it "uses specified port" do
        store = Redis::Store::Factory.create "redis://127.0.0.1:6380"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6380 against DB 0")
      end

      it "uses specified db" do
        store = Redis::Store::Factory.create "redis://127.0.0.1:6380/13"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6380 against DB 13")
      end

      it "uses specified namespace" do
        store = Redis::Store::Factory.create "redis://127.0.0.1:6379/0/theplaylist"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist")
      end

      it "uses specified password" do
        store = Redis::Store::Factory.create "redis://:secret@127.0.0.1:6379/0/theplaylist"
        store.instance_variable_get(:@client).password.must_equal("secret")
      end

      it "correctly uses specified ipv6 host" do
        store = Redis::Store::Factory.create "redis://[::1]:6380"
        store.to_s.must_equal("Redis Client connected to [::1]:6380 against DB 0")
        store.client.host.must_equal("::1")
      end

      it "instantiates Redis::DistributedStore" do
        store = Redis::Store::Factory.create "redis://127.0.0.1:6379", "redis://127.0.0.1:6380"
        store.must_be_kind_of(Redis::DistributedStore)
        store.nodes.map {|node| node.to_s }.must_equal([
          "Redis Client connected to 127.0.0.1:6379 against DB 0",
          "Redis Client connected to 127.0.0.1:6380 against DB 0",
        ])
      end
    end

    describe 'when given host Hash and options Hash' do 
      it 'instantiates Redis::Store and merges options' do
        store = Redis::Store::Factory.create(
          { :host => '127.0.0.1', :port => '6379' }, 
          { :namespace => 'theplaylist' }
        )
      end

      it 'instantiates Redis::DistributedStore and merges options' do 
        store = Redis::Store::Factory.create(
          { :host => '127.0.0.1', :port => '6379' }, 
          { :host => '127.0.0.1', :port => '6380' }, 
          { :namespace => 'theplaylist' }
        )
        store.nodes.map {|node| node.to_s }.must_equal([
          "Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist",
          "Redis Client connected to 127.0.0.1:6380 against DB 0 with namespace theplaylist"
        ])
      end
    end

    describe 'when given host String and options Hash' do 
      it 'instantiates Redis::Store and merges options' do 
        store = Redis::Store::Factory.create "redis://127.0.0.1", { :namespace => 'theplaylist' }
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist")
      end

      it 'instantiates Redis::DistributedStore and merges options' do 
        store = Redis::Store::Factory.create "redis://127.0.0.1:6379", "redis://127.0.0.1:6380", { :namespace => 'theplaylist' }
        store.nodes.map {|node| node.to_s }.must_equal([
          "Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist",
          "Redis Client connected to 127.0.0.1:6380 against DB 0 with namespace theplaylist",
        ])
      end

      it 'instantiates Redis::Store and sets namespace from String' do
        store = Redis::Store::Factory.create "redis://127.0.0.1:6379/0/theplaylist", { :expire_after => 5 }
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist")
      end
    end
  end
end
