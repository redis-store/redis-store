require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "MarshaledRedis" do
  before(:each) do
    @mr = MarshaledRedis.new
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @mr.set "rabbit", @rabbit
  end

  it "should unmarshal an object on get" do
    @mr.get("rabbit").should === @rabbit
  end

  it "should marshal object on set" do
    @mr.set "rabbit", @white_rabbit
    @mr.get("rabbit").should === @white_rabbit
  end

  it "should not unmarshal object on get if raw option is true" do
    @mr.get("rabbit", :raw => true).should == "\004\bU:\017OpenStruct{\006:\tname\"\nbunny"
  end

  it "should not marshal object on set if raw option is true" do
    @mr.set "rabbit", @white_rabbit, :raw => true
    @mr.get("rabbit", :raw => true).should == %(#<OpenStruct color="white">)
  end
end
