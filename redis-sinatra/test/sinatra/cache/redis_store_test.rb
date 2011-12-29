require 'test_helper'

class App
  def initialize
    @values = {}
  end

  def set(key, value)
    @values[key] = value
  end

  def get(key)
    @values[key]
  end
end

describe Sinatra::Cache::RedisStore do
  before do
    @store  = Sinatra::Cache::RedisStore.new
    @dstore = Sinatra::Cache::RedisStore.new "redis://127.0.0.1:6380/1", "redis://127.0.0.1:6381/1"
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    with_store_management do |store|
      store.write  "rabbit", @rabbit
      store.delete "counter"
      store.delete "rub-a-dub"
    end
  end

  it "should register as extension" do
    app = App.new
    Sinatra::Cache.register(app)
    store = app.get(:cache)
    store.must_be_kind_of(Sinatra::Cache::RedisStore)
  end

  it "should read the data" do
    with_store_management do |store|
      store.read("rabbit").must_equal(@rabbit)
    end
  end

  it "should write the data" do
    with_store_management do |store|
      store.write "rabbit", @white_rabbit
      store.read("rabbit").must_equal(@white_rabbit)
    end
  end

  it "should write the data with expiration time" do
    with_store_management do |store|
      store.write "rabbit", @white_rabbit, :expires_in => 1 # second
      # store.read("rabbit").must_equal(@white_rabbit)
      sleep 2
      store.read("rabbit").must_be_nil
    end
  end

  it "should not write data if :unless_exist option is true" do
    with_store_management do |store|
      store.write "rabbit", @white_rabbit, :unless_exist => true
      store.read("rabbit").must_equal(@rabbit)
    end
  end

  it "should read raw data" do
    with_store_management do |store|
      store.read("rabbit", :raw => true).must_equal(Marshal.dump(@rabbit))
    end
  end

  it "should write raw data" do
    with_store_management do |store|
      store.write "rabbit", @white_rabbit, :raw => true
      store.read("rabbit", :raw => true).must_equal(%(#<OpenStruct color="white">))
    end
  end

  it "should delete data" do
    with_store_management do |store|
      store.delete "rabbit"
      store.read("rabbit").must_be_nil
    end
  end

  it "should delete matched data" do
    with_store_management do |store|
      store.delete_matched "rabb*"
      store.read("rabbit").must_be_nil
    end
  end

  it "should verify existence of an object in the store" do
    with_store_management do |store|
      assert store.exist?("rabbit")
      assert ! store.exist?("rab-a-dub")
    end
  end

  it "should increment a key" do
    with_store_management do |store|
      3.times { store.increment "counter" }
      store.read("counter", :raw => true).to_i.must_equal(3)
    end
  end

  it "should decrement a key" do
    with_store_management do |store|
      3.times { store.increment "counter" }
      2.times { store.decrement "counter" }
      store.read("counter", :raw => true).to_i.must_equal(1)
    end
  end

  it "should increment a key by given value" do
    with_store_management do |store|
      store.increment "counter", 3
      store.read("counter", :raw => true).to_i.must_equal(3)
    end
  end

  it "should decrement a key by given value" do
    with_store_management do |store|
      3.times { store.increment "counter" }
      store.decrement "counter", 2
      store.read("counter", :raw => true).to_i.must_equal(1)
    end
  end

  it "should clear the store" do
    with_store_management do |store|
      store.clear
      store.instance_variable_get(:@data).keys("*").flatten.must_be :empty?
    end
  end

  it "should return store stats" do
    with_store_management do |store|
      store.stats.wont_be :empty?
    end
  end

  it "should fetch data" do
    with_store_management do |store|
      store.fetch("rabbit").must_equal(@rabbit)
      store.fetch("rub-a-dub").must_be_nil
      store.fetch("rub-a-dub") { "Flora de Cana" }.must_equal("Flora de Cana")
      store.fetch("rub-a-dub").must_equal("Flora de Cana")
      store.fetch("rabbit", :force => true).must_be_nil # force cache miss
      store.fetch("rabbit", :force => true, :expires_in => 1) { @white_rabbit }
      # store.fetch("rabbit").must_equal(@white_rabbit)
      sleep 2
      store.fetch("rabbit").must_be_nil
    end
  end

  private
    def instantiate_store(addresses = nil)
      Sinatra::Cache::RedisStore.new(addresses).instance_variable_get(:@data)
    end

    def with_store_management
      yield @store
      yield @dstore
    end
end
