require 'test_helper'

describe Redis::Store do
  def setup
    @store  = Redis::Store.new
    @client = @store.instance_variable_get(:@client)
  end

  def teardown
    @store.flushdb
    @store.quit
  end

  it "returns useful informations about the server" do
    @store.to_s.must_equal("Redis Client connected to #{@client.host}:#{@client.port} against DB #{@client.db}")
  end

  it "must force reconnection" do
    @client.expects(:reconnect)
    @store.reconnect
  end

  describe '#set' do
    describe 'with expiry' do
      let(:options) { { :expire_after => 3600 } }

      it 'must not double marshall' do
        Marshal.expects(:dump).once

        @store.set('key', 'value', options)
      end
    end
  end

  describe '#setnx' do
    describe 'with expiry' do
      let(:options) { { :expire_after => 3600 } }

      it 'must not double marshall' do
        Marshal.expects(:dump).once

        @store.setnx('key', 'value', options)
      end
    end
  end
end
