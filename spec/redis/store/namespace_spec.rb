require 'spec_helper'

describe "Redis::Store::Namespace" do
  before :each do
    @namespace = "theplaylist"
    @store  = Redis::Store.new :namespace => @namespace, :marshalling => false # TODO remove mashalling option
    @client = @store.instance_variable_get(:@client)
    @rabbit = "bunny"
  end

  after :each do
    @store.should_receive(:quit) # stupid rspec, meh!
    @store.quit
  end

  it "should only decorate instances that needs to be namespaced" do
    @store = Redis::Store.new
    client = @store.instance_variable_get(:@client)
    client.should_receive(:call).with(:get, "rabbit")
    @store.get("rabbit")
  end

  it "should not namespace a key which is already namespaced" do
    @store.send(:interpolate, "#{@namespace}:rabbit").should == "#{@namespace}:rabbit"
  end

  it "should namespace get" do
    @client.should_receive(:call).with(:get, "#{@namespace}:rabbit")
    @store.get("rabbit")
  end

  it "should namespace set" do
    @client.should_receive(:call).with(:set, "#{@namespace}:rabbit", @rabbit)
    @store.set "rabbit", @rabbit
  end

  it "should namespace setnx" do
    @client.should_receive(:call).with(:setnx, "#{@namespace}:rabbit", @rabbit)
    @store.setnx "rabbit", @rabbit
  end

  it "should namespace del with single key" do
    @client.should_receive(:call).with(:del, "#{@namespace}:rabbit")
    @store.del "rabbit"
  end

  it "should namespace del with multiple keys" do
    @client.should_receive(:call).with(:del, "#{@namespace}:rabbit", "#{@namespace}:white_rabbit")
    @store.del "rabbit", "white_rabbit"
  end

  it "should namespace keys" do
    @client.should_receive(:call).with(:keys, "#{@namespace}:rabb*").and_return [ "#{@namespace}:rabbit" ]
    @store.keys "rabb*"
  end

  it "should namespace exists" do
    @client.should_receive(:call).with(:exists, "#{@namespace}:rabbit")
    @store.exists "rabbit"
  end

  it "should namespace incrby" do
    @client.should_receive(:call).with(:incrby, "#{@namespace}:counter", 1)
    @store.incrby "counter", 1
  end

  it "should namespace decrby" do
    @client.should_receive(:call).with(:decrby, "#{@namespace}:counter", 1)
    @store.decrby "counter", 1
  end

  it "should namespace mget" do
    @client.should_receive(:call).with(:mget, "#{@namespace}:rabbit", "#{@namespace}:white_rabbit")
    @store.mget "rabbit", "white_rabbit"
  end
end
