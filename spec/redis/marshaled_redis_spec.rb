require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "MarshaledRedis" do
  before(:each) do
    @mr = MarshaledRedis.new
    @rabbit = OpenStruct.new :name => "bunny"
  end

  it "should marshal/unmarshal an object on set/get" do
    @mr.set "rabbit", @rabbit
    @mr.get("rabbit").should === @rabbit
  end
end
