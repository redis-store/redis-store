require 'test_helper'

describe Redis::Store::Compression do
  before do
    @store = Redis::Store.new compress: true
    @rabbit = OpenStruct.new :name => "bunny"
    @white_rabbit = OpenStruct.new :color => "white"
    @store.set 'rabbit', @rabbit
  end

  after do
    @store.flushdb
    @store.quit
  end

  it 'decompresses on get' do
    @store.get('rabbit').must_equal(@rabbit)
  end

  it 'compresses on set' do
    @store.set 'rabbit', @white_rabbit

    @store.get('rabbit').must_equal(@white_rabbit)
  end

  it 'compresses on setex' do
    @store.setex 'rabbit', 300, @white_rabbit

    @store.get('rabbit').must_equal(@white_rabbit)
  end

  it 'compresses on setnx' do
    @store.setnx 'rabbit', @white_rabbit

    @store.get('rabbit').must_equal(@rabbit)

    @store.del 'rabbit'
    @store.setnx 'rabbit', @white_rabbit

    @store.get('rabbit').must_equal(@white_rabbit)
  end
end
