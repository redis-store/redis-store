require 'spec_helper'

describe "Redis::Factory" do
  describe ".create" do
    context "when not given any arguments" do
      it "should instantiate a Redis::Store store" do
        store = Redis::Factory.create
        store.should be_kind_of(Redis::Store)
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

      it "should allow to specify namespace" do
        store = Redis::Factory.create :namespace => "theplaylist"
        store.to_s.should == "Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist"
      end

      it "should allow to specify key_prefix as namespace" do
        store = Redis::Factory.create :key_prefix => "theplaylist"
        store.to_s.should == "Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist"
      end

      it "should allow to specify marshalling" do
        store = Redis::Factory.create :marshalling => false
        store.instance_variable_get(:@marshalling).should be_false
      end

      it "should allow to specify password" do
        store = Redis::Factory.create :password => "secret"
        store.instance_variable_get(:@client).password.should == "secret"
      end

      it "should instantiate a Redis::DistributedStore store" do
        store = Redis::Factory.create(
          {:host => "localhost", :port => 6379},
          {:host => "localhost", :port => 6380}
        )
        store.should be_kind_of(Redis::DistributedStore)
        store.nodes.map {|node| node.to_s}.should == [
          "Redis Client connected to localhost:6379 against DB 0",
          "Redis Client connected to localhost:6380 against DB 0",
        ]
      end
    end

    context "when given a String" do
      it "should allow to specify host" do
        store = Redis::Factory.create "redis://127.0.0.1"
        store.to_s.should == "Redis Client connected to 127.0.0.1:6379 against DB 0"
      end

      it "should allow to specify port" do
        store = Redis::Factory.create "redis://127.0.0.1:6380"
        store.to_s.should == "Redis Client connected to 127.0.0.1:6380 against DB 0"
      end

      it "should allow to specify db" do
        store = Redis::Factory.create "redis://127.0.0.1:6380/13"
        store.to_s.should == "Redis Client connected to 127.0.0.1:6380 against DB 13"
      end

      it "should allow to specify namespace" do
        store = Redis::Factory.create "redis://127.0.0.1:6379/0/theplaylist"
        store.to_s.should == "Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist"
      end

      it "should allow to specify scheme" do
        store = Redis::Factory.create "redis://127.0.0.1:6379/0/theplaylist"
        store.to_s.should == "Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist"
      end

      it "should allow to specify password" do
        store = Redis::Factory.create "redis://:secret@127.0.0.1:6379/0/theplaylist"
        store.instance_variable_get(:@client).password.should == "secret"
      end

      it "should allow to specify password without scheme" do
        suppress_warnings do
          store = Redis::Factory.create ":secret@127.0.0.1:6379/0/theplaylist"
          store.instance_variable_get(:@client).password.should == "secret"
        end
      end

      it "should instantiate a Redis::DistributedStore store" do
        store = Redis::Factory.create "redis://127.0.0.1:6379", "redis://127.0.0.1:6380"
        store.should be_kind_of(Redis::DistributedStore)
        store.nodes.map {|node| node.to_s}.should == [
          "Redis Client connected to 127.0.0.1:6379 against DB 0",
          "Redis Client connected to 127.0.0.1:6380 against DB 0",
        ]
      end
    end
  end
end
