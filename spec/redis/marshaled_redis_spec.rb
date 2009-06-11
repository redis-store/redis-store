require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "MarshaledRedis" do
  before(:each) do
    @mr = MarshaledRedis.new
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @mr.set    "rabbit", @rabbit
    @mr.delete "rabbit2"
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

  it "should not unmarshal object if getting an empty string" do
    @mr.set "empty_string", ""
    lambda { @mr.get("empty_string").should == "" }.should_not raise_error
  end

  it "should not set an object if already exist" do
    @mr.set_unless_exists "rabbit", @white_rabbit
    @mr.get("rabbit").should === @rabbit
  end

  it "should marshal object on set_unless_exists" do
    @mr.set_unless_exists "rabbit2", @white_rabbit
    @mr.get("rabbit2").should === @white_rabbit
  end

  it "should not marshal object on set_unless_exists if raw option is true" do
    @mr.set_unless_exists "rabbit2", @white_rabbit, :raw => true
    @mr.get("rabbit2", :raw => true).should == %(#<OpenStruct color="white">)
  end
end
