require 'test_helper'

module StubInterface
  def setex(key, ttl, value, options = nil)
    stub_op(:setex, key, ttl, value, options)
  end

  def setnx(key, value, options = nil)
    stub_op(:setnx, key, value, options)
  end

  def stub_op(op, key, value, options)
  end
end

class RedisWithTtl < Redis
  include StubInterface, Redis::Store::Ttl
end

describe RedisWithTtl do
  describe 'an instance' do
    let(:key) { 'hello' }
    let(:value) { 'value' }
    let(:options) { { :expire_after => 3600 } }
    let(:redis) { RedisWithTtl.new }

    it 'must respond to set' do
      redis.must_respond_to(:set)
    end

    it 'must respond to setnx' do
      redis.must_respond_to(:setnx)
    end

    describe '#set' do
      describe 'without options' do
        it 'must call super with key and value' do
          RedisWithTtl.any_instance.expects(:super).with(key, value)

          redis.set(key, value)
        end
      end

      describe 'with options' do
        it 'must call setex with proper expiry and set raw to true' do
          RedisWithTtl.any_instance.expects(:stub_op).with(:setex, key, options[:expire_after], value, :raw => true)

          redis.set(key, value, options)
        end
      end
    end

    describe '#setnx' do
      describe 'without expiry' do
        it 'must call super with key and value' do
          RedisWithTtl.any_instance.expects(:super).with(key, value)

          redis.setnx(key, value)
        end

        it 'must not call expire' do
          RedisWithTtl.any_instance.expects(:expire).never

          redis.setnx(key, value)
        end
      end

      describe 'with expiry' do
        it 'must call setnx with key and value and set raw to true' do
          RedisWithTtl.any_instance.expects(:stub_op).with(:setnx, key, value, :raw => true)
        end

        it 'must call expire' do
          RedisWithTtl.any_instance.expects(:expire).with(key, options[:expire_after])

          redis.setnx(key, value, options)
        end
      end
    end
  end
end
