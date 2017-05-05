require 'test_helper'

class InterfacedRedis < Redis
  include Redis::Store::Interface
end

describe Redis::Store::Interface do
  before do
    @r = InterfacedRedis.new
  end

  it "should get an element" do
    assert_nil @r.get("key", :option => true)
  end

  it "should set an element" do
    assert @r.set("key", "value", :option => true)
  end

  it "should setnx an element" do
    assert @r.del("key")
    assert @r.setnx("key", "value", :option => true)
  end

  it "should setex an element" do
    assert @r.del("key")
    assert @r.setex("key", 1, "value", :option => true)
  end
end
