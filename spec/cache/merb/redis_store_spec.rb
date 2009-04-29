require File.join(File.dirname(__FILE__), "/../../spec_helper")

module Merb
  module Cache
    describe "RedisStore" do
      before(:each) do
        @store  = RedisStore.new
        @dstore = RedisStore.new :servers => ["localhost:6380/1", "localhost:6381/1"]
        @rabbit = OpenStruct.new :name => "bunny"
        @white_rabbit = OpenStruct.new :color => "white"
        with_store_management do |store|
          store.write  "rabbit", @rabbit
          store.delete "counter"
        end
      end

      it "should accept connection params" do
        redis = instantiate_store
        redis.instance_variable_get(:@db).should == 0
        redis.host.should == "localhost"
        redis.port.should == "6379"

        redis = instantiate_store "redis.com"
        redis.host.should == "redis.com"
        
        redis = instantiate_store "redis.com:6380"
        redis.host.should == "redis.com"
        redis.port.should == "6380"

        redis = instantiate_store "redis.com:6380/23"
        redis.instance_variable_get(:@db).should == 23
        redis.host.should == "redis.com"
        redis.port.should == "6380"
      end
      
      it "should instantiate a ring" do
        store = instantiate_store
        store.should be_kind_of(MarshaledRedis)
        store = instantiate_store ["localhost:6379/0", "localhost:6379/1"]
        store.should be_kind_of(DistributedMarshaledRedis)
      end

      it "should verify if writeable"

      it "should read the data" do
        with_store_management do |store|
          store.read("rabbit").should === @rabbit
        end
      end

      it "should read raw data" do
        with_store_management do |store|
          store.read("rabbit", {}, :raw => true).should == "\004\bU:\017OpenStruct{\006:\tname\"\nbunny"
        end
      end

      it "should write the data" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit
          store.read("rabbit").should === @white_rabbit
        end
      end

      it "should write raw data" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit, {}, :raw => true
          store.read("rabbit", {}, :raw => true).should == %(#<OpenStruct color="white">)
        end
      end

      it "should not write data if :unless_exist option is true" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit, {}, :unless_exist => true
          store.read("rabbit").should === @rabbit
        end
      end

      it "should fetch data"
      it "should verify existence"
      it "should delete data"
      it "should delete all the data"
      it "should delete all the data with the bang!"

      private
        def instantiate_store(addresses = nil)
          RedisStore.new(:servers => [addresses].flatten).instance_variable_get(:@data)
        end

        def with_store_management
          yield @store
          yield @dstore
        end
    end
  end
end
