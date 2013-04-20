require 'spec_helper'

describe "Redis::Store::Strategy::Marshal" do
  before(:each) do
    @store = Redis::Store.new :strategy => :marshal
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @store.set "rabbit", @rabbit
    @store.del "rabbit2"
  end

  after :each do
    @store.quit
  end

  it "unmarshals on get" do
    @store.get("rabbit").should == (@rabbit)
  end

  it "marshals on set" do
    @store.set "rabbit", @white_rabbit
    @store.get("rabbit").should == (@white_rabbit)
  end

  if RUBY_VERSION.match /1\.9/
    it "doesn't unmarshal on get if raw option is true" do
      @store.get("rabbit", :raw => true).should == ("\x04\bU:\x0FOpenStruct{\x06:\tnameI\"\nbunny\x06:\x06EF")
    end
  else
    it "doesn't unmarshal on get if raw option is true" do
      @store.get("rabbit", :raw => true).should == ("\004\bU:\017OpenStruct{\006:\tname\"\nbunny")
    end
  end

  it "doesn't marshal on set if raw option is true" do
    @store.set "rabbit", @white_rabbit, :raw => true
    @store.get("rabbit", :raw => true).should == (%(#<OpenStruct color="white">))
  end

  it "doesn't unmarshal if get returns an empty string" do
    @store.set "empty_string", ""
    @store.get("empty_string").should == ("")
    # TODO use a meaningful Exception
    # lambda { @store.get("empty_string").should == ("") }.wont_raise Exception
  end

  it "doesn't set an object if already exist" do
    @store.setnx "rabbit", @white_rabbit
    @store.get("rabbit").should == (@rabbit)
  end

  it "marshals on set unless exists" do
    @store.setnx "rabbit2", @white_rabbit
    @store.get("rabbit2").should == (@white_rabbit)
  end

  it "doesn't marshal on set unless exists if raw option is true" do
    @store.setnx "rabbit2", @white_rabbit, :raw => true
    @store.get("rabbit2", :raw => true).should == (%(#<OpenStruct color="white">))
  end

  it "doesn't unmarshal on multi get" do
    @store.set "rabbit2", @white_rabbit
    rabbit, rabbit2 = @store.mget "rabbit", "rabbit2"
    rabbit.should == (@rabbit)
    rabbit2.should == (@white_rabbit)
  end

  if RUBY_VERSION.match /1\.9/
    it "doesn't unmarshal on multi get if raw option is true" do
      @store.set "rabbit2", @white_rabbit
      rabbit, rabbit2 = @store.mget "rabbit", "rabbit2", :raw => true
      rabbit.should == ("\x04\bU:\x0FOpenStruct{\x06:\tnameI\"\nbunny\x06:\x06EF")
      rabbit2.should == ("\x04\bU:\x0FOpenStruct{\x06:\ncolorI\"\nwhite\x06:\x06EF")
    end
  else
    it "doesn't unmarshal on multi get if raw option is true" do
      @store.set "rabbit2", @white_rabbit
      rabbit, rabbit2 = @store.mget "rabbit", "rabbit2", :raw => true
      rabbit.should == ("\004\bU:\017OpenStruct{\006:\tname\"\nbunny")
      rabbit2.should == ("\004\bU:\017OpenStruct{\006:\ncolor\"\nwhite")
    end
  end

  describe "binary safety" do
    before do
      @utf8_key = [51339].pack("U*")
      @ascii_string = [128].pack("C*")
      @ascii_rabbit = OpenStruct.new(:name => @ascii_string)
    end

    it "marshals objects" do
      @store.set(@utf8_key, @ascii_rabbit)
      @store.get(@utf8_key).should == (@ascii_rabbit)
    end

    it "gets and sets raw values" do
      @store.set(@utf8_key, @ascii_string, :raw => true)
      @store.get(@utf8_key, :raw => true).bytes.to_a.should == (@ascii_string.bytes.to_a)
    end

    it "marshals objects on setnx" do
      @store.del(@utf8_key)
      @store.setnx(@utf8_key, @ascii_rabbit)
      @store.get(@utf8_key).should == (@ascii_rabbit)
    end

    it "gets and sets raw values on setnx" do
      @store.del(@utf8_key)
      @store.setnx(@utf8_key, @ascii_string, :raw => true)
      @store.get(@utf8_key, :raw => true).bytes.to_a.should == (@ascii_string.bytes.to_a)
    end
  end if defined?(Encoding)
end
