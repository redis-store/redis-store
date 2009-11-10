require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "MarshaledRedis" do
  before :all do
    start_detached_redis
  end

  before(:each) do
    @r = MarshaledRedis.new
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @r.set    "rabbit", @rabbit
    @r.delete "rabbit2"
  end

  after :all do
    stop_detached_redis
  end

  it "should unmarshal an object on get" do
    @r.get("rabbit").should === @rabbit
  end

  it "should marshal object on set" do
    @r.set "rabbit", @white_rabbit
    @r.get("rabbit").should === @white_rabbit
  end

  it "should not unmarshal object on get if raw option is true" do
    @r.get("rabbit", :raw => true).should == "\004\bU:\017OpenStruct{\006:\tname\"\nbunny"
  end

  it "should not marshal object on set if raw option is true" do
    @r.set "rabbit", @white_rabbit, :raw => true
    @r.get("rabbit", :raw => true).should == %(#<OpenStruct color="white">)
  end

  it "should not unmarshal object if getting an empty string" do
    @r.set "empty_string", ""
    lambda { @r.get("empty_string").should == "" }.should_not raise_error
  end

  it "should not set an object if already exist" do
    @r.set_unless_exists "rabbit", @white_rabbit
    @r.get("rabbit").should === @rabbit
  end

  it "should marshal object on set_unless_exists" do
    @r.set_unless_exists "rabbit2", @white_rabbit
    @r.get("rabbit2").should === @white_rabbit
  end

  it "should not marshal object on set_unless_exists if raw option is true" do
    @r.set_unless_exists "rabbit2", @white_rabbit, :raw => true
    @r.get("rabbit2", :raw => true).should == %(#<OpenStruct color="white">)
  end
end

