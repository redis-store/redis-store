require 'spec_helper'

describe "Redis::Store::Strategy::JsonSession" do
  before(:each) do
    @marshal_store = Redis::Store.new :strategy => :marshal
    @store = Redis::Store.new :strategy => :json_session
    @rabbit = {:name => "rabbit", :legs => 4}
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
    race = @rabbit.to_json
    @store.get("rabbit", :raw => true).should eql(%({"name":"Bunnicula","race":#{race},"friends":[{"name":"Peter Cottontail","race":#{race}}],"age":3.1,"alive":true}))
  end

  it "doesn't marshal on set if raw option is true" do
    race = @rabbit
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
    race = @rabbit
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
    race = @rabbit.to_json
    rabbit.should eql(%({"name":"Bunnicula","race":#{race},"friends":[{"name":"Peter Cottontail","race":#{race}}],"age":3.1,"alive":true}))
    rabbit2.should eql(%({"name":"Peter Cottontail","race":#{race}}))
  end

  it "will throw an error if an object isn't supported" do
    lambda{
      @store.set "rabbit2", OpenStruct.new(foo:'bar')
    }.should raise_error Redis::Store::Strategy::JsonSession::SerializationError
  end

  it "is able to bring out data that is marshalled using Ruby" do
    @marshal_store.set "rabbit", @peter
    rabbit = @store.get "rabbit"
    rabbit.should eql(@peter)
  end

  context "binary safety" do
    before do
      @utf8_key = [51339].pack("U*")
      @ascii_string = [128].pack("C*")
      @ascii_rabbit = {:name => "rabbit", :legs => 4, :ascii_string => @ascii_string}
    end

    it "gets and sets raw values" do
      @store.set(@utf8_key, @ascii_string, :raw => true)
      @store.get(@utf8_key, :raw => true).bytes.to_a.should eql(@ascii_string.bytes.to_a)
    end

    it "marshals objects on setnx" do
      @store.del(@utf8_key)
      @store.setnx(@utf8_key, @ascii_rabbit)
      retrievied_ascii_rabbit = @store.get(@utf8_key)
      retrievied_ascii_rabbit.except(:ascii_string).should eql(@ascii_rabbit.except(:ascii_string))
      JSON.load(JSON.generate(retrievied_ascii_rabbit[:ascii_string])).should eql(@ascii_string)
    end

    it "gets and sets raw values on setnx" do
      @store.del(@utf8_key)
      @store.setnx(@utf8_key, @ascii_string, :raw => true)
      @store.get(@utf8_key, :raw => true).bytes.to_a.should eql(@ascii_string.bytes.to_a)
    end
  end if defined?(Encoding)
end
