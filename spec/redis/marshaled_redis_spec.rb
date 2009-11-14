require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "MarshaledRedis" do
  before(:each) do
    @store = MarshaledRedis.new
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @store.set    "rabbit", @rabbit
    @store.delete "rabbit2"
  end

  after :each do
    @store.quit
  end

  it "should unmarshal an object on get" do
    @store.get("rabbit").should === @rabbit
  end

  it "should marshal object on set" do
    @store.set "rabbit", @white_rabbit
    @store.get("rabbit").should === @white_rabbit
  end

  it "should not unmarshal object on get if raw option is true" do
    @store.get("rabbit", :raw => true).should == "\004\bU:\017OpenStruct{\006:\tname\"\nbunny"
  end

  it "should not marshal object on set if raw option is true" do
    @store.set "rabbit", @white_rabbit, :raw => true
    @store.get("rabbit", :raw => true).should == %(#<OpenStruct color="white">)
  end

  it "should not unmarshal object if getting an empty string" do
    @store.set "empty_string", ""
    lambda { @store.get("empty_string").should == "" }.should_not raise_error
  end

  it "should not set an object if already exist" do
    @store.set_unless_exists "rabbit", @white_rabbit
    @store.get("rabbit").should === @rabbit
  end

  it "should marshal object on set_unless_exists" do
    @store.set_unless_exists "rabbit2", @white_rabbit
    @store.get("rabbit2").should === @white_rabbit
  end

  it "should not marshal object on set_unless_exists if raw option is true" do
    @store.set_unless_exists "rabbit2", @white_rabbit, :raw => true
    @store.get("rabbit2", :raw => true).should == %(#<OpenStruct color="white">)
  end
end

