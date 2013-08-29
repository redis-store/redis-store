require 'test_helper'

describe "Redis::Store::Namespace" do
  def setup
    @namespace = "theplaylist"
    @store  = Redis::Store.new :namespace => @namespace, :marshalling => false # TODO remove mashalling option
    @client = @store.instance_variable_get(:@client)
    @rabbit = "bunny"
  end

  def teardown
    @store.quit
  end

  it "only decorates instances that need to be namespaced" do
    store  = Redis::Store.new
    client = store.instance_variable_get(:@client)
    client.expects(:call).with([:get, "rabbit"])
    store.get("rabbit")
  end

  it "doesn't namespace a key which is already namespaced" do
    @store.send(:interpolate, "#{@namespace}:rabbit").must_equal("#{@namespace}:rabbit")
  end

  it "should only delete namespaced keys" do
    other_store = Redis::Store.new

    other_store.set 'abc', 'cba'
    @store.set 'def', 'fed'

    @store.flushdb
    @store.get('def').must_equal(nil)
    other_store.get('abc').must_equal('cba')
  end

  it "should not try to delete missing namespaced keys" do
    empty_store = Redis::Store.new :namespace => 'empty'
    empty_store.flushdb
    empty_store.keys.must_be_empty
  end

  it "namespaces get"
  it "namespaces set"
  it "namespaces setnx"
  it "namespaces del with single key"
  it "namespaces del with multiple keys"
  it "namespaces keys"
  it "namespaces exists"
  it "namespaces incrby"
  it "namespaces decrby"
  it "namespaces mget"

  # it "should namespace get" do
  #   @client.expects(:call).with([:get, "#{@namespace}:rabbit"]).once
  #   @store.get("rabbit")
  # end
  #
  # it "should namespace set" do
  #   @client.should_receive(:call).with([:set, "#{@namespace}:rabbit", @rabbit])
  #   @store.set "rabbit", @rabbit
  # end
  #
  # it "should namespace setnx" do
  #   @client.should_receive(:call).with([:setnx, "#{@namespace}:rabbit", @rabbit])
  #   @store.setnx "rabbit", @rabbit
  # end
  #
  # it "should namespace del with single key" do
  #   @client.should_receive(:call).with([:del, "#{@namespace}:rabbit"])
  #   @store.del "rabbit"
  # end
  #
  # it "should namespace del with multiple keys" do
  #   @client.should_receive(:call).with([:del, "#{@namespace}:rabbit", "#{@namespace}:white_rabbit"])
  #   @store.del "rabbit", "white_rabbit"
  # end
  #
  # it "should namespace keys" do
  #   @store.set "rabbit", @rabbit
  #   @store.keys("rabb*").should == [ "rabbit" ]
  # end
  #
  # it "should namespace exists" do
  #   @client.should_receive(:call).with([:exists, "#{@namespace}:rabbit"])
  #   @store.exists "rabbit"
  # end
  #
  # it "should namespace incrby" do
  #   @client.should_receive(:call).with([:incrby, "#{@namespace}:counter", 1])
  #   @store.incrby "counter", 1
  # end
  #
  # it "should namespace decrby" do
  #   @client.should_receive(:call).with([:decrby, "#{@namespace}:counter", 1])
  #   @store.decrby "counter", 1
  # end
  #
  # it "should namespace mget" do
  #   @client.should_receive(:call).with([:mget, "#{@namespace}:rabbit", "#{@namespace}:white_rabbit"])
  #   @store.mget "rabbit", "white_rabbit"
  # end
end
