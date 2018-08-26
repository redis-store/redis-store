require 'test_helper'
require 'json'

describe "Redis::Store::Factory" do
  describe ".create" do
    describe "when not given any arguments" do
      it "instantiates Redis::Store" do
        store = Redis::Store::Factory.create
        store.must_be_kind_of(Redis::Store)
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0")
      end
    end

    describe "when given a Hash" do
      it "uses specified host" do
        store = Redis::Store::Factory.create :host => "localhost"
        store.to_s.must_equal("Redis Client connected to localhost:6379 against DB 0")
      end

      it "uses specified port" do
        store = Redis::Store::Factory.create :host => "localhost", :port => 6380
        store.to_s.must_equal("Redis Client connected to localhost:6380 against DB 0")
      end

      it "uses specified scheme" do
        store = Redis::Store::Factory.create :scheme => "rediss"
        store.instance_variable_get(:@client).scheme.must_equal('rediss')
      end

      it "uses specified path" do
        store = Redis::Store::Factory.create :path => "/var/run/redis.sock"
        store.to_s.must_equal("Redis Client connected to /var/run/redis.sock against DB 0")
      end

      it "uses specified db" do
        store = Redis::Store::Factory.create :host => "localhost", :port => 6380, :db => 13
        store.to_s.must_equal("Redis Client connected to localhost:6380 against DB 13")
      end

      it "uses specified namespace" do
        store = Redis::Store::Factory.create :namespace => "theplaylist"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist")
      end

      it "uses specified key_prefix as namespace" do
        store = Redis::Store::Factory.create :key_prefix => "theplaylist"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist")
      end

      it "uses specified password" do
        store = Redis::Store::Factory.create :password => "secret"
        store.instance_variable_get(:@client).password.must_equal("secret")
      end

      it 'uses empty password' do
        store = Redis::Store::Factory.create :password => ''
        store.instance_variable_get(:@client).password.must_equal('')
      end

      it 'uses nil password' do
        store = Redis::Store::Factory.create :password => nil
        assert_nil(store.instance_variable_get(:@client).password)
      end

      it "disables serialization" do
        store = Redis::Store::Factory.create :serializer => nil
        store.instance_variable_get(:@serializer).must_be_nil
        store.instance_variable_get(:@options)[:raw].must_equal(true)
      end

      it "configures pluggable serialization backend" do
        store = Redis::Store::Factory.create :serializer => JSON
        store.instance_variable_get(:@serializer).must_equal(JSON)
        store.instance_variable_get(:@options)[:raw].must_equal(false)
      end

      describe "defaults" do
        it "defaults to localhost if no host specified" do
          store = Redis::Store::Factory.create
          store.instance_variable_get(:@client).host.must_equal('127.0.0.1')
        end

        it "defaults to 6379 if no port specified" do
          store = Redis::Store::Factory.create
          store.instance_variable_get(:@client).port.must_equal(6379)
        end

        it "defaults to redis:// if no scheme specified" do
          store = Redis::Store::Factory.create
          store.instance_variable_get(:@client).scheme.must_equal('redis')
        end
      end

      describe 'with stdout disabled' do
        before do
          @original_stderr = $stderr
          @original_stdout = $stdout

          $stderr = Tempfile.new('stderr')
          $stdout = Tempfile.new('stdout')
        end

        it "disables marshalling and provides deprecation warning" do
          store = Redis::Store::Factory.create :marshalling => false
          store.instance_variable_get(:@serializer).must_be_nil
          store.instance_variable_get(:@options)[:raw].must_equal(true)
        end

        it "enables marshalling but provides warning to use :serializer instead" do
          store = Redis::Store::Factory.create :marshalling => true
          store.instance_variable_get(:@serializer).must_equal(Marshal)
          store.instance_variable_get(:@options)[:raw].must_equal(false)
        end

        after do
          $stderr = @original_stderr
          $stdout = @original_stdout
        end
      end

      it "should instantiate a Redis::DistributedStore store" do
        store = Redis::Store::Factory.create(
          { :host => "localhost", :port => 6379 },
          { :host => "localhost", :port => 6380 }
        )
        store.must_be_kind_of(Redis::DistributedStore)
        store.nodes.map { |node| node.to_s }.must_equal([
          "Redis Client connected to localhost:6379 against DB 0",
          "Redis Client connected to localhost:6380 against DB 0",
        ])
      end
    end

    describe "when given a String" do
      it "uses specified host" do
        store = Redis::Store::Factory.create "redis://127.0.0.1"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0")
      end

      it "uses specified port" do
        store = Redis::Store::Factory.create "redis://127.0.0.1:6380"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6380 against DB 0")
      end

      it "uses specified scheme" do
        store = Redis::Store::Factory.create "rediss://127.0.0.1:6380"
        store.instance_variable_get(:@client).scheme.must_equal('rediss')
      end

      it "correctly defaults to redis:// when relative scheme specified" do
        store = Redis::Store::Factory.create "//127.0.0.1:6379"
        store.instance_variable_get(:@client).scheme.must_equal('redis')
      end

      it "uses specified path" do
        store = Redis::Store::Factory.create "unix:///var/run/redis.sock"
        store.to_s.must_equal("Redis Client connected to /var/run/redis.sock against DB 0")
      end

      it "uses specified db" do
        store = Redis::Store::Factory.create "redis://127.0.0.1:6380/13"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6380 against DB 13")
      end

      it "uses specified namespace" do
        store = Redis::Store::Factory.create "redis://127.0.0.1:6379/0/theplaylist"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist")
      end

      it "uses specified via query namespace" do
        store = Redis::Store::Factory.create "redis://127.0.0.1:6379/0?namespace=theplaylist"
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist")
      end

      it "uses specified namespace with path" do
        store = Redis::Store::Factory.create "unix:///var/run/redis.sock?db=2&namespace=theplaylist"
        store.to_s.must_equal("Redis Client connected to /var/run/redis.sock against DB 2 with namespace theplaylist")
      end

      it "uses specified password" do
        store = Redis::Store::Factory.create "redis://:secret@127.0.0.1:6379/0/theplaylist"
        store.instance_variable_get(:@client).password.must_equal("secret")
      end

      it 'uses specified password with special characters' do
        store = Redis::Store::Factory.create 'redis://:pwd%40123@127.0.0.1:6379/0/theplaylist'
        store.instance_variable_get(:@client).password.must_equal('pwd@123')
      end

      it 'uses empty password' do
        store = Redis::Store::Factory.create 'redis://:@127.0.0.1:6379/0/theplaylist'
        store.instance_variable_get(:@client).password.must_equal('')
      end

      it 'uses nil password' do
        store = Redis::Store::Factory.create 'redis://127.0.0.1:6379/0/theplaylist'
        assert_nil(store.instance_variable_get(:@client).password)
      end

      it "correctly uses specified ipv6 host" do
        store = Redis::Store::Factory.create "redis://[::1]:6380"
        store.to_s.must_equal("Redis Client connected to [::1]:6380 against DB 0")
        store.instance_variable_get('@options')[:host].must_equal("::1")
      end

      it "instantiates Redis::DistributedStore" do
        store = Redis::Store::Factory.create "redis://127.0.0.1:6379", "redis://127.0.0.1:6380"
        store.must_be_kind_of(Redis::DistributedStore)
        store.nodes.map { |node| node.to_s }.must_equal([
          "Redis Client connected to 127.0.0.1:6379 against DB 0",
          "Redis Client connected to 127.0.0.1:6380 against DB 0",
        ])
      end
    end

    describe 'when given host Hash and options Hash' do
      it 'instantiates Redis::Store and merges options' do
        store = Redis::Store::Factory.create(
          { :host => '127.0.0.1', :port => '6379' },
          { :namespace => 'theplaylist' }
        )
      end

      it 'instantiates Redis::DistributedStore and merges options' do
        store = Redis::Store::Factory.create(
          { :host => '127.0.0.1', :port => '6379' },
          { :host => '127.0.0.1', :port => '6380' },
          { :namespace => 'theplaylist' }
        )
        store.nodes.map { |node| node.to_s }.must_equal([
          "Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist",
          "Redis Client connected to 127.0.0.1:6380 against DB 0 with namespace theplaylist"
        ])
      end
    end

    describe 'when given host String and options Hash' do
      it 'instantiates Redis::Store and merges options' do
        store = Redis::Store::Factory.create "redis://127.0.0.1", :namespace => 'theplaylist'
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist")
      end

      it 'instantiates Redis::DistributedStore and merges options' do
        store = Redis::Store::Factory.create "redis://127.0.0.1:6379", "redis://127.0.0.1:6380", :namespace => 'theplaylist'
        store.nodes.map { |node| node.to_s }.must_equal([
          "Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist",
          "Redis Client connected to 127.0.0.1:6380 against DB 0 with namespace theplaylist",
        ])
      end

      it 'instantiates Redis::Store and sets namespace from String' do
        store = Redis::Store::Factory.create "redis://127.0.0.1:6379/0/theplaylist", :expire_after => 5
        store.to_s.must_equal("Redis Client connected to 127.0.0.1:6379 against DB 0 with namespace theplaylist")
      end
    end
  end
end
