require 'spec_helper'

describe "Redis::Store::Strategy::Json" do
  before(:each) do
    @store = Redis::Store.new :strategy => :json
    @rabbit = OpenStruct.new :name => 'rabbit', :legs => 4
    @peter     = { :name => "Peter Cottontail",
                   :race => @rabbit }
    @bunnicula = { :name    => "Bunnicula",
                   :race    => @rabbit,
                   :friends => [@peter],
                   :age     => 3.1,
                   :alive   => true }
    @store.set "rabbit", @bunnicula
    @store.del "rabbit2"
  end

  after :each do
    @store.quit
  end

  it "unmarshals on get" do
    @store.get("rabbit").should eql(@bunnicula)
  end

  it "marshals on set" do
    @store.set "rabbit", @peter
    @store.get("rabbit").should eql(@peter)
  end

  it "doesn't unmarshal on get if raw option is true" do
    race = Marshal.dump(@rabbit).to_json
    @store.get("rabbit", :raw => true).should eql(%({"name":"Bunnicula","race":#{race},"friends":[{"name":"Peter Cottontail","race":#{race}}],"age":3.1,"alive":true}))
  end

  it "doesn't marshal on set if raw option is true" do
    race = Marshal.dump(@rabbit)
    @store.set "rabbit", @peter, :raw => true
    @store.get("rabbit", :raw => true).should eql(%({:name=>"Peter Cottontail", :race=>#{race.inspect}}))
  end

  it "doesn't set an object if already exist" do
    @store.setnx "rabbit", @peter
    @store.get("rabbit").should eql(@bunnicula)
  end

  it "marshals on set unless exists" do
    @store.setnx "rabbit2", @peter
    @store.get("rabbit2").should eql(@peter)
  end

  it "doesn't marshal on set unless exists if raw option is true" do
    @store.setnx "rabbit2", @peter, :raw => true
    race = Marshal.dump(@rabbit)
    @store.get("rabbit2", :raw => true).should eql(%({:name=>"Peter Cottontail", :race=>#{race.inspect}}))
  end

  it "doesn't unmarshal on multi get" do
    @store.set "rabbit2", @peter
    rabbit, rabbit2 = @store.mget "rabbit", "rabbit2"
    rabbit.should eql(@bunnicula)
    rabbit2.should eql(@peter)
  end

  it "doesn't unmarshal on multi get if raw option is true" do
    @store.set "rabbit", @bunnicula
    @store.set "rabbit2", @peter
    rabbit, rabbit2 = @store.mget "rabbit", "rabbit2", :raw => true
    race = Marshal.dump(@rabbit).to_json
    rabbit.should eql(%({"name":"Bunnicula","race":#{race},"friends":[{"name":"Peter Cottontail","race":#{race}}],"age":3.1,"alive":true}))
    rabbit2.should eql(%({"name":"Peter Cottontail","race":#{race}}))
  end

  describe "binary safety" do
    before do
      @utf8_key = [51339].pack("U*")
      @ascii_string = [128].pack("C*")
      @ascii_rabbit = OpenStruct.new(:name => @ascii_string)
    end

    it "marshals objects"
      # @store.set(@utf8_key, @ascii_rabbit)
      # @store.get(@utf8_key).should eql(@ascii_rabbit)

    it "gets and sets raw values" do
      @store.set(@utf8_key, @ascii_string, :raw => true)
      @store.get(@utf8_key, :raw => true).bytes.to_a.should eql(@ascii_string.bytes.to_a)
    end

    it "marshals objects on setnx"
      # @store.del(@utf8_key)
      # @store.setnx(@utf8_key, @ascii_rabbit)
      # @store.get(@utf8_key).should eql(@ascii_rabbit)

    it "gets and sets raw values on setnx" do
      @store.del(@utf8_key)
      @store.setnx(@utf8_key, @ascii_string, :raw => true)
      @store.get(@utf8_key, :raw => true).bytes.to_a.should eql(@ascii_string.bytes.to_a)
    end
  end if defined?(Encoding)
end
