require 'test_helper'

describe "Redis::Marshalling" do
  def setup
    @store = Redis::Store.new :marshalling => true
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @store.set "rabbit", @rabbit
    @store.del "rabbit2"
  end

  def teardown
    @store.quit
  end

  it "unmarshals on get" do
    @store.get("rabbit").must_equal(@rabbit)
  end

  it "marshals on set" do
    @store.set "rabbit", @white_rabbit
    @store.get("rabbit").must_equal(@white_rabbit)
  end

  if RUBY_VERSION.match /1\.9/
    it "doesn't unmarshal on get if raw option is true" do
      @store.get("rabbit", :raw => true).must_equal("\x04\bU:\x0FOpenStruct{\x06:\tnameI\"\nbunny\x06:\x06EF")
    end
  else
    it "doesn't unmarshal on get if raw option is true" do
      @store.get("rabbit", :raw => true).must_include("\x04\bU:\x0FOpenStruct{\x06:\tname")
    end
  end

  it "doesn't marshal set if raw option is true" do
    @store.set "rabbit", @white_rabbit, :raw => true
    @store.get("rabbit", :raw => true).must_equal(%(#<OpenStruct color="white">))
  end

  it "doesn't unmarshal if get returns an empty string" do
    @store.set "empty_string", ""
    @store.get("empty_string").must_equal("")
    # TODO use a meaningful Exception
    # lambda { @store.get("empty_string").must_equal("") }.wont_raise Exception
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
    @store.get("rabbit2", :raw => true).must_equal(%(#<OpenStruct color="white">))
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

  if RUBY_VERSION.match /1\.9/
    it "doesn't unmarshal on multi get if raw option is true" do
      @store.set "rabbit2", @white_rabbit
      rabbit, rabbit2 = @store.mget "rabbit", "rabbit2", :raw => true
      rabbit.must_equal("\x04\bU:\x0FOpenStruct{\x06:\tnameI\"\nbunny\x06:\x06EF")
      rabbit2.must_equal("\x04\bU:\x0FOpenStruct{\x06:\ncolorI\"\nwhite\x06:\x06EF")
    end
  else
    it "doesn't unmarshal on multi get if raw option is true" do
      @store.set "rabbit2", @white_rabbit
      rabbit, rabbit2 = @store.mget "rabbit", "rabbit2", :raw => true
      rabbit.must_include("\x04\bU:\x0FOpenStruct{\x06:\tname")
      rabbit2.must_include("\x04\bU:\x0FOpenStruct{\x06:\ncolor")
    end
  end

  describe "binary safety" do
    it "marshals objects" do
      utf8_key = [51339].pack("U*")
      ascii_rabbit = OpenStruct.new(:name => [128].pack("C*"))

      @store.set(utf8_key, ascii_rabbit)
      @store.get(utf8_key).must_equal(ascii_rabbit)
    end

    it "gets and sets raw values" do
      utf8_key = [51339].pack("U*")
      ascii_string = [128].pack("C*")

      @store.set(utf8_key, ascii_string, :raw => true)
      @store.get(utf8_key, :raw => true).bytes.to_a.must_equal(ascii_string.bytes.to_a)
    end

    it "marshals objects on setnx" do
      utf8_key = [51339].pack("U*")
      ascii_rabbit = OpenStruct.new(:name => [128].pack("C*"))

      @store.del(utf8_key)
      @store.setnx(utf8_key, ascii_rabbit)
      @store.get(utf8_key).must_equal(ascii_rabbit)
    end

    it "gets and sets raw values on setnx" do
      utf8_key = [51339].pack("U*")
      ascii_string = [128].pack("C*")

      @store.del(utf8_key)
      @store.setnx(utf8_key, ascii_string, :raw => true)
      @store.get(utf8_key, :raw => true).bytes.to_a.must_equal(ascii_string.bytes.to_a)
    end
  end if defined?(Encoding)
end