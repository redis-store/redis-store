require 'spec_helper'
RAILS_SESSION_STORE_CLASS = ::Redis::Store.rails3? ? ActionDispatch::Session::RedisSessionStore : ActionController::Session::RedisSessionStore

describe RAILS_SESSION_STORE_CLASS do
  attr_reader :app

  before :each do
    @app = Object.new
    @store  = RAILS_SESSION_STORE_CLASS.new(app)
    @dstore = RAILS_SESSION_STORE_CLASS.new app, :servers => ["redis://127.0.0.1:6380/1", "redis://127.0.0.1:6381/1"]
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @sid = "rabbit"
    @env = {'rack.session.options' => {:id => @sid}}
    with_store_management do |store|
      class << store
        attr_reader :pool
        public :get_session, :set_session, :destroy
      end
      store.set_session(@env, @sid, @rabbit)
      store.pool.del "counter"
      store.pool.del "rub-a-dub"
    end
  end

  it "should accept string connection params" do
    redis = instantiate_store
    redis.to_s.should == "Redis Client connected to localhost:6379 against DB 0"

    redis = instantiate_store :servers => "redis://localhost"
    redis.to_s.should == "Redis Client connected to localhost:6379 against DB 0"

    redis = instantiate_store :servers => "redis://localhost:6380"
    redis.to_s.should == "Redis Client connected to localhost:6380 against DB 0"

    redis = instantiate_store :servers => "redis://localhost:6380/13"
    redis.to_s.should == "Redis Client connected to localhost:6380 against DB 13"

    redis = instantiate_store :servers => "redis://localhost:6380/13/theplaylist"
    redis.to_s.should == "Redis Client connected to localhost:6380 against DB 13 with namespace theplaylist"
  end

  it "should accept hash connection params" do
    redis = instantiate_store :servers => [{ :host => "192.168.0.1" }]
    redis.to_s.should == "Redis Client connected to 192.168.0.1:6379 against DB 0"

    redis = instantiate_store :servers => [{ :port => "6380" }]
    redis.to_s.should == "Redis Client connected to 127.0.0.1:6380 against DB 0"

    redis = instantiate_store :servers => [{ :db => 13 }]
    redis.to_s.should == "Redis Client connected to 127.0.0.1:6379 against DB 13"

    redis = instantiate_store :servers => [{ :key_prefix => "theplaylist" }]
    redis.to_s.should == "Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist"
  end

  it "should accept options when :servers key isn't passed" do
    redis = RAILS_SESSION_STORE_CLASS.new(app, :key_prefix => "theplaylist").instance_variable_get(:@pool)
    redis.to_s.should == "Redis Client connected to localhost:6379 against DB 0 with namespace theplaylist"
  end

  it "should instantiate a ring" do
    store = instantiate_store
    store.should be_kind_of(Redis::Store)
    store = instantiate_store :servers => ["redis://127.0.0.1:6379/0", "redis://127.0.0.1:6379/1"]
    store.should be_kind_of(Redis::DistributedStore)
  end

  it "should read the data" do
    with_store_management do |store|
      store.get_session(@env, @sid).should === [@sid, @rabbit]
    end
  end

  it "should write the data" do
    with_store_management do |store|
      store.set_session(@env, @sid, @white_rabbit)
      store.get_session(@env, @sid).should === [@sid, @white_rabbit]
    end
  end

  it "should delete the data" do
    with_store_management do |store|
      store.destroy(@env)
      store.get_session(@env, @sid).should === [@sid, {}]
    end
  end

  it "should write the data with expiration time" do
    with_store_management do |store|
      @env['rack.session.options'].merge!(:expires_in => 1.second)
      store.set_session(@env, @sid, @white_rabbit)
      store.get_session(@env, @sid).should === [@sid, @white_rabbit]; sleep 2
      store.get_session(@env, @sid).should === [@sid, {}]
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
      @client.should_receive(:call).with(:get, "#{@namespace}:#{@sid}")
      @store.send :get_session, @env, @sid
    end

    it "should write the data" do
      @client.should_receive(:call).with(:set, "#{@namespace}:#{@sid}", Marshal.dump(@white_rabbit))
      @store.send :set_session, @env, @sid, @white_rabbit
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
