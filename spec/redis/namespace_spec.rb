require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "Redis::Namespace" do
  before :each do
    @namespace = "theplaylist"
    @store = Redis::MarshaledClient.new :namespace => @namespace
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @store.marshalled_set "rabbit", @rabbit
    @store.del "rabbit2"
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

  it "should namespace marshalled_get" do
    client = @store.instance_variable_get(:@client)
    client.should_receive(:call).with(:get, "#{@namespace}:rabbit")
    @store.marshalled_get("rabbit")
  end

  it "should namespace marshalled_set" do
    @store.should_receive(:set).with("#{@namespace}:rabbit", Marshal.dump(@white_rabbit))
    @store.marshalled_set "rabbit", @white_rabbit
  end

  it "should namespace marshalled_setnx" do
    @store.should_receive(:setnx).with("#{@namespace}:rabbit", Marshal.dump(@white_rabbit))
    @store.marshalled_setnx "rabbit", @white_rabbit
  end
end
