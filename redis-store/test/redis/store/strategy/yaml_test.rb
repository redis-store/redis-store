require 'test_helper'

describe "Redis::Store::Strategy::Yaml" do
  def setup
    @store = Redis::Store.new :strategy => :yaml
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @store.set "rabbit", @rabbit
    @store.del "rabbit2"
  end

  def teardown
    @store.quit
  end

  # Psych::YAML had a bug in which it could not properly serialize binary Strings
  # in Ruby 1.9.3.  The issue was addressed in 1.9.3-p125.
  def self.binary_encodable_yaml?
    RUBY_VERSION != '1.9.3' or RUBY_PATCHLEVEL >= 125
  end

  it "unmarshals on get" do
    @store.get("rabbit").must_equal(@rabbit)
  end

  it "marshals on set" do
    @store.set "rabbit", @white_rabbit
    @store.get("rabbit").must_equal(@white_rabbit)
  end

  it "doesn't unmarshal on get if raw option is true" do
    @store.get("rabbit", :raw => true).must_equal("--- !ruby/object:OpenStruct\ntable:\n  :name: bunny\n")
  end

  it "doesn't marshal on set if raw option is true" do
    @store.set "rabbit", @white_rabbit, :raw => true
    @store.get("rabbit", :raw => true).must_equal(%(#<OpenStruct color=\"white\">))
  end

  it "doesn't set an object if already exist" do
    @store.setnx "rabbit", @white_rabbit
    @store.get("rabbit").must_equal(@rabbit)
  end

  it "marshals on set unless exists" do
    @store.setnx "rabbit2", @white_rabbit
    @store.get("rabbit2").must_equal(@white_rabbit)
  end

  it "doesn't marshal on set unless exists if raw option is true" do
    @store.setnx "rabbit2", @white_rabbit, :raw => true
    @store.get("rabbit2", :raw => true).must_equal(%(#<OpenStruct color=\"white\">))
  end

  it "marshals on set expire" do
    @store.setex "rabbit2", 1, @white_rabbit
    @store.get("rabbit2").must_equal(@white_rabbit)
    sleep 2
    @store.get("rabbit2").must_be_nil
  end

  it "doesn't unmarshal on multi get" do
    @store.set "rabbit2", @white_rabbit
    rabbit, rabbit2 = @store.mget "rabbit", "rabbit2"
    rabbit.must_equal(@rabbit)
    rabbit2.must_equal(@white_rabbit)
  end

  it "doesn't unmarshal on multi get if raw option is true" do
    @store.set "rabbit2", @white_rabbit
    rabbit, rabbit2 = @store.mget "rabbit", "rabbit2", :raw => true
    rabbit.must_equal("--- !ruby/object:OpenStruct\ntable:\n  :name: bunny\n")
    rabbit2.must_equal("--- !ruby/object:OpenStruct\ntable:\n  :color: white\n")
  end

  describe "binary safety" do
    before do
      @utf8_key = [51339].pack("U*")
      @ascii_string = [128].pack("C*")
      @ascii_rabbit = OpenStruct.new(:name => @ascii_string)
    end

    it "marshals objects" do
      @store.set(@utf8_key, @ascii_rabbit)
      @store.get(@utf8_key).must_equal(@ascii_rabbit)
    end

    it "gets and sets raw values" do
      @store.set(@utf8_key, @ascii_string, :raw => true)
      @store.get(@utf8_key, :raw => true).bytes.to_a.must_equal(@ascii_string.bytes.to_a)
    end

    it "marshals objects on setnx" do
      @store.del(@utf8_key)
      @store.setnx(@utf8_key, @ascii_rabbit)
      @store.get(@utf8_key).must_equal(@ascii_rabbit)
    end

    it "gets and sets raw values on setnx" do
      @store.del(@utf8_key)
      @store.setnx(@utf8_key, @ascii_string, :raw => true)
      @store.get(@utf8_key, :raw => true).bytes.to_a.must_equal(@ascii_string.bytes.to_a)
    end
  end if defined?(Encoding) && binary_encodable_yaml?
end