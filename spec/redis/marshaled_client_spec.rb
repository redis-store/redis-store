require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "Redis::MarshaledClient" do
  before(:each) do
    @store = Redis::MarshaledClient.new
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @store.marshalled_set "rabbit", @rabbit
    @store.del "rabbit2"
  end

  after :each do
    @store.quit
  end

  it "should unmarshal an object on get" do
    @store.marshalled_get("rabbit").should === @rabbit
  end

  it "should marshal object on set" do
    @store.marshalled_set "rabbit", @white_rabbit
    @store.marshalled_get("rabbit").should === @white_rabbit
  end

  it "should not unmarshal object on get if raw option is true" do
    @store.marshalled_get("rabbit", :raw => true).should == "\004\bU:\017OpenStruct{\006:\tname\"\nbunny"
  end

  it "should not marshal object on set if raw option is true" do
    @store.marshalled_set "rabbit", @white_rabbit, :raw => true
    @store.marshalled_get("rabbit", :raw => true).should == %(#<OpenStruct color="white">)
  end

  it "should not unmarshal object if getting an empty string" do
    @store.marshalled_set "empty_string", ""
    lambda { @store.marshalled_get("empty_string").should == "" }.should_not raise_error
  end

  it "should not set an object if already exist" do
    @store.marshalled_setnx "rabbit", @white_rabbit
    @store.marshalled_get("rabbit").should === @rabbit
  end

  it "should marshal object on set_unless_exists" do
    @store.marshalled_setnx "rabbit2", @white_rabbit
    @store.marshalled_get("rabbit2").should === @white_rabbit
  end

  it "should not marshal object on set_unless_exists if raw option is true" do
    @store.marshalled_setnx "rabbit2", @white_rabbit, :raw => true
    @store.marshalled_get("rabbit2", :raw => true).should == %(#<OpenStruct color="white">)
  end
end

