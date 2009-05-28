require File.join(File.dirname(__FILE__), "/../../../spec_helper")

module Rack
  module Cache
    class EntityStore
      describe "Rack::Cache::EntityStore::Redis" do
        before(:each) do
          @store = Rack::Cache::EntityStore::Redis.new :host => "localhost"
        end

        it "should have the class referenced by homonym constant" do
          Rack::Cache::EntityStore::REDIS.should be(Rack::Cache::EntityStore::Redis)
        end

        it "should resolve the connection uri" do
          cache = Rack::Cache::EntityStore::Redis.resolve(uri("redis://127.0.0.1")).cache
          cache.should be_kind_of(::Redis)
          cache.host.should == "127.0.0.1"
          cache.port.should == 6379
          cache.db.should == 0

          cache = Rack::Cache::EntityStore::Redis.resolve(uri("redis://127.0.0.1:6380")).cache
          cache.port.should == 6380

          cache = Rack::Cache::EntityStore::Redis.resolve(uri("redis://127.0.0.1/13")).cache
          cache.db.should == 13
        end

        it 'responds to all required messages' do
          %w[read open write exist?].each do |message|
            @store.should respond_to(message)
          end
        end

        it 'stores bodies with #write' do
          key, size = @store.write(['My wild love went riding,'])
          key.should_not be_nil
          # key.should be_sha_like TODO re-enable

          data = @store.read(key)
          data.should == 'My wild love went riding,'
        end

        it 'correctly determines whether cached body exists for key with #exist?' do
          key, size = @store.write(['She rode to the devil,'])
          @store.should be_exist(key)
          @store.should_not be_exist('938jasddj83jasdh4438021ksdfjsdfjsdsf')
        end

        it 'can read data written with #write' do
          key, size = @store.write(['And asked him to pay.'])
          data = @store.read(key)
          data.should == 'And asked him to pay.'
        end

        it 'gives a 40 character SHA1 hex digest from #write' do
          key, size = @store.write(['she rode to the sea;'])
          key.should_not be_nil
          key.length.should == 40
          key.should =~ /^[0-9a-z]+$/
          key.should == '90a4c84d51a277f3dafc34693ca264531b9f51b6'
        end

        it 'returns the entire body as a String from #read' do
          key, size = @store.write(['She gathered together'])
          @store.read(key).should == 'She gathered together'
        end

        it 'returns nil from #read when key does not exist' do
          @store.read('87fe0a1ae82a518592f6b12b0183e950b4541c62').should be_nil
        end

        it 'returns a Rack compatible body from #open' do
          key, size = @store.write(['Some shells for her hair.'])
          body = @store.open(key)
          body.should respond_to(:each)
          buf = ''
          body.each { |part| buf << part }
          buf.should == 'Some shells for her hair.'
        end

        it 'returns nil from #open when key does not exist' do
          @store.open('87fe0a1ae82a518592f6b12b0183e950b4541c62').should be_nil
        end

        it 'can store largish bodies with binary data' do
          pony = ::File.open(::File.dirname(__FILE__) + '/pony.jpg', 'rb') { |f| f.read }
          key, size = @store.write([pony])
          key.should == 'd0f30d8659b4d268c5c64385d9790024c2d78deb'
          data = @store.read(key)
          data.length.should == pony.length
          data.hash.should == pony.hash
        end

        it 'deletes stored entries with #purge' do
          key, size = @store.write(['My wild love went riding,'])
          @store.purge(key).should be_nil
          @store.read(key).should be_nil
        end

        private
          def uri(uri)
            URI.parse uri
          end
      end
    end
  end
end
