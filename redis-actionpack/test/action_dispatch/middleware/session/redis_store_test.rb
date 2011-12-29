require 'test_helper'

describe ActionDispatch::Session::RedisSessionStore do
  attr_reader :app

  before do
    @app = Object.new
    @store  = ActionDispatch::Session::RedisSessionStore.new(app)
    @dstore = ActionDispatch::Session::RedisSessionStore.new app, :servers => ["redis://127.0.0.1:6380/1", "redis://127.0.0.1:6381/1"]
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

  it "reads the data" do
    with_store_management do |store|
      store.get_session(@env, @sid).must_equal([@sid, @rabbit])
    end
  end

  it "should write the data" do
    with_store_management do |store|
      store.set_session(@env, @sid, @white_rabbit)
      store.get_session(@env, @sid).must_equal([@sid, @white_rabbit])
    end
  end

  it "should delete the data" do
    with_store_management do |store|
      store.destroy(@env)
      store.get_session(@env, @sid).must_equal([@sid, {}])
    end
  end

  it "should write the data with expiration time" do
    with_store_management do |store|
      @env['rack.session.options'].merge!(:expires_in => 1.second)
      store.set_session(@env, @sid, @white_rabbit); sleep 2
      store.get_session(@env, @sid).must_equal([@sid, {}])
    end
  end

  describe "namespace" do
    before do
      @namespace = "theplaylist"
      @store  = ActionDispatch::Session::RedisSessionStore.new(lambda {|| }, :servers => [{ :namespace => @namespace }])
      @pool   = @store.instance_variable_get(:@pool)
      @client = @pool.instance_variable_get(:@client)
    end

    it "should read the data" do
      @client.expects(:call).with([:get, "#{@namespace}:#{@sid}"])
      @store.send :get_session, @env, @sid
    end

    it "should write the data" do
      @client.expects(:call).with([:set, "#{@namespace}:#{@sid}", Marshal.dump(@white_rabbit)])
      @store.send :set_session, @env, @sid, @white_rabbit
    end
  end

  private
    def with_store_management
      yield @store
      yield @dstore
    end
end