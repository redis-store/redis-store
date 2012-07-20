require 'test_helper'

class Object
  def sha_like?
    length == 40 && self =~ /^[0-9a-z]+$/
  end
end

describe Rack::Cache::EntityStore::Redis do
  before do
    @store = ::Rack::Cache::EntityStore::Redis.new :host => 'localhost'
  end

  it 'has the class referenced by homonym constant' do
    ::Rack::Cache::EntityStore::REDIS.must_equal(::Rack::Cache::EntityStore::Redis)
  end

  it 'resolves the connection uri' do
    cache = ::Rack::Cache::EntityStore::Redis.resolve(uri("redis://127.0.0.1")).cache
    cache.must_be_kind_of(::Redis)
    cache.id.must_equal("redis://127.0.0.1:6379/0")

    cache = ::Rack::Cache::EntityStore::Redis.resolve(uri("redis://127.0.0.1:6380")).cache
    cache.id.must_equal("redis://127.0.0.1:6380/0")

    cache = ::Rack::Cache::EntityStore::Redis.resolve(uri("redis://127.0.0.1/13")).cache
    cache.id.must_equal("redis://127.0.0.1:6379/13")

    cache = ::Rack::Cache::EntityStore::Redis.resolve(uri("redis://:secret@127.0.0.1")).cache
    cache.id.must_equal("redis://127.0.0.1:6379/0")
    cache.client.password.must_equal('secret')
    
    cache = Rack::Cache::MetaStore::Redis.resolve(uri("redis://127.0.0.1:6380/0/entitystore")).cache
    cache.to_s.must_equal("Redis Client connected to 127.0.0.1:6380 against DB 0 with namespace entitystore")
  end

  it 'responds to all required messages' do
    %w[read open write exist?].each do |message|
      @store.must_respond_to message
    end
  end

  it 'stores bodies with #write' do
    key, size = @store.write(['My wild love went riding,'])
    key.wont_be_nil
    key.must_be :sha_like?

    data = @store.read(key)
    data.must_equal('My wild love went riding,')
  end

  it 'takes a ttl parameter for #write' do
    key, size = @store.write(['My wild love went riding,'], 0)
    key.wont_be_nil
    key.must_be :sha_like?

    data = @store.read(key)
    data.must_equal('My wild love went riding,')
  end

  it 'correctly determines whether cached body exists for key with #exist?' do
    key, size = @store.write(['She rode to the devil,'])
    assert @store.exist?(key)
    assert ! @store.exist?('938jasddj83jasdh4438021ksdfjsdfjsdsf')
  end

  it 'can read data written with #write' do
    key, size = @store.write(['And asked him to pay.'])
    data = @store.read(key)
    data.must_equal('And asked him to pay.')
  end

  it 'gives a 40 character SHA1 hex digest from #write' do
    key, size = @store.write(['she rode to the sea;'])
    key.wont_be_nil
    key.length.must_equal(40)
    key.must_match(/^[0-9a-z]+$/)
    key.must_equal('90a4c84d51a277f3dafc34693ca264531b9f51b6')
  end

  it 'returns the entire body as a String from #read' do
    key, size = @store.write(['She gathered together'])
    @store.read(key).must_equal('She gathered together')
  end

  it 'returns nil from #read when key does not exist' do
    @store.read('87fe0a1ae82a518592f6b12b0183e950b4541c62').must_be_nil
  end

  it 'returns a Rack compatible body from #open' do
    key, size = @store.write(['Some shells for her hair.'])
    body = @store.open(key)
    body.must_respond_to :each
    buf = ''
    body.each { |part| buf << part }
    buf.must_equal('Some shells for her hair.')
  end

  it 'returns nil from #open when key does not exist' do
    @store.open('87fe0a1ae82a518592f6b12b0183e950b4541c62').must_be_nil
  end

  if RUBY_VERSION < '1.9'
    it 'can store largish bodies with binary data' do
      pony = File.open(File.dirname(__FILE__) + '/pony.jpg', 'rb') { |f| f.read }
      key, size = @store.write([pony])
      key.must_equal('d0f30d8659b4d268c5c64385d9790024c2d78deb')
      data = @store.read(key)
      data.length.must_equal(pony.length)
      data.hash.must_equal(pony.hash)
    end
  end

  it 'deletes stored entries with #purge' do
    key, size = @store.write(['My wild love went riding,'])
    @store.purge(key).must_be_nil
    @store.read(key).must_be_nil
  end

  private
    define_method :uri do |uri|
      URI.parse uri
    end
end