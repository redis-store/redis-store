require 'spec_helper'

class InterfacedRedis < Redis
  include Redis::Store::Interface
end

describe "Redis::Store::Interface" do
  before :each do
    @r = InterfacedRedis.new
  end

  it "should get an element" do
    lambda { @r.get("key", :option => true) }.should_not raise_error
  end

  it "should set an element" do
    lambda { @r.set("key", "value", :option => true) }.should_not raise_error
  end

  it "should setnx an element" do
    lambda { @r.setnx("key", "value", :option => true) }.should_not raise_error
  end
end