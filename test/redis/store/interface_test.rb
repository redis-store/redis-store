require 'test_helper'

class InterfacedRedis < Redis
  include Redis::Store::Interface
end

class CustomOptions
  def initialize(options)
    @delegate = options.dup
  end

  def [](key)
    @delegate[key]
  end
end

describe Redis::Store::Interface do
  before do
    @r = InterfacedRedis.new
  end

  it "should get an element" do
    @r.get("key", :option => true) # .wont_raise ArgumentError
  end

  it "should set an element without options" do
    @r.set("key", "value") # .wont_raise ArgumentError
  end

  it "should set an element with options" do
    @r.set("key", "value", :option => true) # .wont_raise ArgumentError
  end

  it "should set an element with custom options object" do
    @r.set("key", "value", CustomOptions.new(:option => true)) # .wont_raise ArgumentError
  end

  it "should setnx an element" do
    @r.setnx("key", "value", :option => true) # .wont_raise ArgumentError
  end

  it "should setex an element" do
    @r.setex("key", 1, "value", :option => true) # .wont_raise ArgumentError
  end
end
