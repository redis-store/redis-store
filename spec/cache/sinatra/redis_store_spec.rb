require 'spec_helper'

class App
  def initialize
    @values = {}
  end

  def set(key, value)
    @values[key] = value
  end

  def get(key)
    @values[key]
  end
end

module Sinatra
  module Cache
    describe "Sinatra::Cache::RedisStore" do
      before(:each) do
        @store  = Sinatra::Cache::RedisStore.new
        @dstore = Sinatra::Cache::RedisStore.new "redis://127.0.0.1:6380/1", "redis://127.0.0.1:6381/1"
        @rabbit = OpenStruct.new :name => "bunny"
        @white_rabbit = OpenStruct.new :color => "white"
        with_store_management do |store|
          store.write  "rabbit", @rabbit
          store.delete "counter"
          store.delete "rub-a-dub"
        end
      end

      it "should register as extension" do
        app = App.new
        Sinatra::Cache.register(app)
        store = app.get(:cache)
        store.should be_kind_of(RedisStore)
      end

      it "should accept connection params" do
        redis = instantiate_store
        redis.to_s.should == "Redis Client connected to 127.0.0.1:6379 against DB 0"

        redis = instantiate_store "redis://127.0.0.1"
        redis.to_s.should == "Redis Client connected to 127.0.0.1:6379 against DB 0"

        redis = instantiate_store "redis://127.0.0.1:6380"
        redis.to_s.should == "Redis Client connected to 127.0.0.1:6380 against DB 0"

        redis = instantiate_store "redis://127.0.0.1:6380/13"
        redis.to_s.should == "Redis Client connected to 127.0.0.1:6380 against DB 13"

        redis = instantiate_store "redis://127.0.0.1:6380/13/theplaylist"
        redis.to_s.should == "Redis Client connected to 127.0.0.1:6380 against DB 13 with namespace theplaylist"
      end

      it "should instantiate a ring" do
        store = instantiate_store
        store.should be_kind_of(Redis::Store)
        store = instantiate_store ["redis://127.0.0.1:6379/0", "redis://127.0.0.1:6379/1"]
        store.should be_kind_of(Redis::DistributedStore)
      end

      it "should read the data" do
        with_store_management do |store|
          store.read("rabbit").should === @rabbit
        end
      end

      it "should write the data" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit
          store.read("rabbit").should === @white_rabbit
        end
      end

      it "should write the data with expiration time" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit, :expires_in => 1.second
          store.read("rabbit").should === @white_rabbit ; sleep 2
          store.read("rabbit").should be_nil
        end
      end

      it "should not write data if :unless_exist option is true" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit, :unless_exist => true
          store.read("rabbit").should === @rabbit
        end
      end

      it "should read raw data" do
        with_store_management do |store|
          store.read("rabbit", :raw => true).should == Marshal.dump(@rabbit)
        end
      end

      it "should write raw data" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit, :raw => true
          store.read("rabbit", :raw => true).should == %(#<OpenStruct color="white">)
        end
      end

      it "should delete data" do
        with_store_management do |store|
          store.delete "rabbit"
          store.read("rabbit").should be_nil
        end
      end

      it "should delete matched data" do
        with_store_management do |store|
          store.delete_matched "rabb*"
          store.read("rabbit").should be_nil
        end
      end

      it "should verify existence of an object in the store" do
        with_store_management do |store|
          store.exist?("rabbit").should be_true
          store.exist?("rab-a-dub").should be_false
        end
      end

      it "should increment a key" do
        with_store_management do |store|
          3.times { store.increment "counter" }
          store.read("counter", :raw => true).to_i.should == 3
        end
      end

      it "should decrement a key" do
        with_store_management do |store|
          3.times { store.increment "counter" }
          2.times { store.decrement "counter" }
          store.read("counter", :raw => true).to_i.should == 1
        end
      end

      it "should increment a key by given value" do
        with_store_management do |store|
          store.increment "counter", 3
          store.read("counter", :raw => true).to_i.should == 3
        end
      end

      it "should decrement a key by given value" do
        with_store_management do |store|
          3.times { store.increment "counter" }
          store.decrement "counter", 2
          store.read("counter", :raw => true).to_i.should == 1
        end
      end

      it "should clear the store" do
        with_store_management do |store|
          store.clear
          store.instance_variable_get(:@data).keys("*").flatten.should be_empty
        end
      end

      it "should return store stats" do
        with_store_management do |store|
          store.stats.should_not be_empty
        end
      end

      it "should fetch data" do
        with_store_management do |store|
          store.fetch("rabbit").should == @rabbit
          store.fetch("rub-a-dub").should be_nil
          store.fetch("rub-a-dub") { "Flora de Cana" }
          store.fetch("rub-a-dub").should === "Flora de Cana"
          store.fetch("rabbit", :force => true).should be_nil # force cache miss
          store.fetch("rabbit", :force => true, :expires_in => 1.second) { @white_rabbit }
          store.fetch("rabbit").should === @white_rabbit ; sleep 2
          store.fetch("rabbit").should be_nil
        end
      end

      private
        def instantiate_store(addresses = nil)
          Sinatra::Cache::RedisStore.new(addresses).instance_variable_get(:@data)
        end

        def with_store_management
          yield @store
          yield @dstore
        end
    end
  end
end
