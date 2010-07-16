require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "Redis::Namespace" do
  before :each do
    @namespace = "theplaylist"
    @store  = Redis::MarshaledClient.new :namespace => @namespace
    @client = @store.instance_variable_get(:@client)
    @rabbit = OpenStruct.new :name => "bunny"
  end

  after :each do
    @store.should_receive(:quit) # stupid rspec, meh!
    @store.quit
  end

  it "should only decorate instances that needs to be namespaced" do
    @store = Redis::MarshaledClient.new
    client = @store.instance_variable_get(:@client)
    client.should_receive(:call).with(:get, "rabbit")
    @store.marshalled_get("rabbit")
  end

  it "should not namespace a key which is already namespaced" do
    @store.send(:interpolate, "#{@namespace}:rabbit").should == "#{@namespace}:rabbit"
  end

  it "should namespace marshalled_get" do
    @client.should_receive(:call).with(:get, "#{@namespace}:rabbit")
    @store.marshalled_get("rabbit")
  end

  it "should namespace marshalled_set" do
    @store.should_receive(:set).with("#{@namespace}:rabbit", Marshal.dump(@rabbit))
    @store.marshalled_set "rabbit", @rabbit
  end

  it "should namespace marshalled_setnx" do
    @store.should_receive(:setnx).with("#{@namespace}:rabbit", Marshal.dump(@rabbit))
    @store.marshalled_setnx "rabbit", @rabbit
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
