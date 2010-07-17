require 'spec_helper'
RAILS_SESSION_STORE_CLASS = ::RedisStore.rails3? ? ActionDispatch::Session::RedisSessionStore : ActionController::Session::RedisSessionStore

describe RAILS_SESSION_STORE_CLASS do
  attr_reader :app

  before :each do
    @app = Object.new
    @store  = RAILS_SESSION_STORE_CLASS.new(app)
    @dstore = RAILS_SESSION_STORE_CLASS.new app, :servers => ["localhost:6380/1", "localhost:6381/1"]
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    with_store_management do |store|
      class << store
        attr_reader :pool
        public :get_session, :set_session
      end
      store.set_session({'rack.session.options' => {}}, "rabbit", @rabbit)
      store.pool.del "counter"
      store.pool.del "rub-a-dub"
    end
  end

  it "should accept string connection params" do
    redis = instantiate_store
    redis.to_s.should == "Redis Client connected to 127.0.0.1:6379 against DB 0"

    redis = instantiate_store :servers => "localhost"
    redis.to_s.should == "Redis Client connected to localhost:6379 against DB 0"

    redis = instantiate_store :servers => "localhost:6380"
    redis.to_s.should == "Redis Client connected to localhost:6380 against DB 0"

    redis = instantiate_store :servers => "localhost:6380/13"
    redis.to_s.should == "Redis Client connected to localhost:6380 against DB 13"

    redis = instantiate_store :servers => "localhost:6380/13/theplaylist"
    redis.to_s.should == "Redis Client connected to localhost:6380 against DB 13 with namespace theplaylist"
  end

  it "should accept hash connection params" do
    redis = instantiate_store :servers => [{ :host => "192.168.0.1" }]
    redis.to_s.should == "Redis Client connected to 192.168.0.1:6379 against DB 0"

    redis = instantiate_store :servers => [{ :port => "6380" }]
    redis.to_s.should == "Redis Client connected to localhost:6380 against DB 0"

    redis = instantiate_store :servers => [{ :db => 13 }]
    redis.to_s.should == "Redis Client connected to localhost:6379 against DB 13"

    redis = instantiate_store :servers => [{ :key_prefix => "theplaylist" }]
    redis.to_s.should == "Redis Client connected to localhost:6379 against DB 0 with namespace theplaylist"
  end

  it "should instantiate a ring" do
    store = instantiate_store
    store.should be_kind_of(Redis::Store)
    store = instantiate_store :servers => ["localhost:6379/0", "localhost:6379/1"]
    store.should be_kind_of(Redis::DistributedMarshaled)
  end

  it "should read the data" do
    with_store_management do |store|
      store.get_session({}, "rabbit").should === ["rabbit", @rabbit]
    end
  end

  it "should write the data" do
    with_store_management do |store|
      store.set_session({"rack.session.options" => {}}, "rabbit", @white_rabbit)
      store.get_session({}, "rabbit").should === ["rabbit", @white_rabbit]
    end
  end

  it "should write the data with expiration time" do
    with_store_management do |store|
      store.set_session({"rack.session.options" => {:expires_in => 1.second}}, "rabbit", @white_rabbit)
      store.get_session({}, "rabbit").should === ["rabbit", @white_rabbit]; sleep 2
      store.get_session({}, "rabbit").should === ["rabbit", {}]
    end
  end

  describe "namespace" do
    before :each do
      @namespace = "theplaylist"
      @store  = RAILS_SESSION_STORE_CLASS.new(lambda {|| }, :servers => [{ :namespace => @namespace }])
      @pool   = @store.instance_variable_get(:@pool)
      @client = @pool.instance_variable_get(:@client)
    end

    it "should read the data" do
      @client.should_receive(:call).with(:get, "#{@namespace}:rabbit")
      @store.send :get_session, {}, "rabbit"
    end

    it "should write the data" do
      @client.should_receive(:call).with(:set, "#{@namespace}:rabbit", Marshal.dump(@white_rabbit))
      @store.send :set_session, {"rack.session.options" => {}}, "rabbit", @white_rabbit
    end
  end

  private
    def instantiate_store(params = { })
      RAILS_SESSION_STORE_CLASS.new(app, params).instance_variable_get(:@pool)
    end

    def with_store_management
      yield @store
      yield @dstore
    end
end
