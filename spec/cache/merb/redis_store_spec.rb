require 'spec_helper'

module Merb
  module Cache
    describe "Merb::Cache::RedisStore" do
      before(:each) do
        @store  = Merb::Cache::RedisStore.new
        @dstore = Merb::Cache::RedisStore.new :servers => ["redis://127.0.0.1:6380/1", "redis://127.0.0.1:6381/1"]
        @rabbit = OpenStruct.new :name => "bunny"
        @white_rabbit = OpenStruct.new :color => "white"
        with_store_management do |store|
          store.write "rabbit", @rabbit
          store.delete "rub-a-dub"
        end
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

      it "should verify if writable" do
        with_store_management do |store|
          store.writable?("rabbit").should be_true
        end
      end

      it "should read the data" do
        with_store_management do |store|
          store.read("rabbit").should === @rabbit
        end
      end

      it "should read raw data" do
        with_store_management do |store|
          store.read("rabbit", {}, :raw => true).should == Marshal.dump(@rabbit)
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

      it "should write the data with expiration time" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit, {}, :expires_in => 1.second
          store.read("rabbit").should === @white_rabbit ; sleep 2
          store.read("rabbit").should be_nil
        end
      end

      it "should not write data if :unless_exist option is true" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit, {}, :unless_exist => true
          store.read("rabbit").should === @rabbit
        end
      end

      it "should write all the data" do
        with_store_management do |store|
          store.write_all "rabbit", @white_rabbit
          store.read("rabbit").should === @white_rabbit
        end
      end

      it "should fetch data" do
        with_store_management do |store|
          store.fetch("rabbit").should == @rabbit
          store.fetch("rub-a-dub").should be_nil
          store.fetch("rub-a-dub") { "Flora de Cana" }
          store.fetch("rub-a-dub").should === "Flora de Cana"
        end
      end

      it "should verify existence" do
        with_store_management do |store|
          store.exists?("rabbit").should be_true
          store.exists?("rab-a-dub").should be_false
        end
      end

      it "should delete data" do
        with_store_management do |store|
          store.delete "rabbit"
          store.read("rabbit").should be_nil
        end
      end

      it "should delete all the data" do
        with_store_management do |store|
          store.delete_all
          store.instance_variable_get(:@data).keys("*").flatten.should be_empty
        end
      end

      it "should delete all the data with bang method" do
        with_store_management do |store|
          store.delete_all!
          store.instance_variable_get(:@data).keys("*").flatten.should be_empty
        end
      end

      private
        def instantiate_store(addresses = nil)
          Merb::Cache::RedisStore.new(:servers => [addresses].flatten).instance_variable_get(:@data)
        end

        def with_store_management
          yield @store
          yield @dstore
        end
    end
  end
end
