require File.join(File.dirname(__FILE__), "/../../../spec_helper")

module Rack
  module Cache
    class MetaStore
      describe "Rack::Cache::MetaStore::Redis" do
        before(:each) do
          @store = Rack::Cache::MetaStore::Redis.resolve uri("redis://127.0.0.1")
        end

        it "should have the class referenced by homonym constant" do
          Rack::Cache::MetaStore::REDIS.should be(Rack::Cache::MetaStore::Redis)
        end

        it "should resolve the connection uri" do
          cache = Rack::Cache::MetaStore::Redis.resolve(uri("redis://127.0.0.1")).cache
          cache.should be_kind_of(::MarshaledRedis)
          cache.host.should == "127.0.0.1"
          cache.port.should == 6379
          cache.db.should == 0

          cache = Rack::Cache::MetaStore::Redis.resolve(uri("redis://127.0.0.1:6380")).cache
          cache.port.should == 6380

          cache = Rack::Cache::MetaStore::Redis.resolve(uri("redis://127.0.0.1/13")).cache
          cache.db.should == 13
        end

        it 'writes a list of negotation tuples with #write' do
          lambda { @store.write('/test', [[{}, {}]]) }.should_not raise_error
        end

        it 'reads a list of negotation tuples with #read' do
          @store.write('/test', [[{},{}],[{},{}]])
          tuples = @store.read('/test')
          tuples.should == [ [{},{}], [{},{}] ]
        end

        it 'reads an empty list with #read when nothing cached at key' do
          @store.read('/nothing').should be_empty
        end

        it 'removes entries for key with #purge' do
          @store.write('/test', [[{},{}]])
          @store.read('/test').should_not be_empty

          @store.purge('/test')
          @store.read('/test').should be_empty
        end

        it 'succeeds when purging non-existing entries' do
          @store.read('/test').should be_empty
          @store.purge('/test')
        end

        it 'returns nil from #purge' do
          @store.write('/test', [[{},{}]])
          @store.purge('/test').should be_nil
          @store.read('/test').should == []
        end

        %w[/test http://example.com:8080/ /test?x=y /test?x=y&p=q].each do |key|
          it "can read and write key: '#{key}'" do
            lambda { @store.write(key, [[{},{}]]) }.should_not raise_error
            @store.read(key).should == [[{},{}]]
          end
        end

        it "can read and write fairly large keys" do
          key = "b" * 4096
          lambda { @store.write(key, [[{},{}]]) }.should_not raise_error
          @store.read(key).should == [[{},{}]]
        end

        it "allows custom cache keys from block" do
          request = mock_request('/test', {})
          request.env['rack-cache.cache_key'] =
            lambda { |request| request.path_info.reverse }
          @store.cache_key(request).should == 'tset/'
        end

        it "allows custom cache keys from class" do
          request = mock_request('/test', {})
          request.env['rack-cache.cache_key'] = Class.new do
            def self.call(request); request.path_info.reverse end
          end
          @store.cache_key(request).should == 'tset/'
        end

        private
          def mock_request(uri, opts)
            env = Rack::MockRequest.env_for(uri, opts || {})
            Rack::Cache::Request.new(env)
          end

          def uri(uri)
            URI.parse uri
          end
      end
    end
  end
end
