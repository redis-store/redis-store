require 'test_helper'

class RedisWithTtl < Redis
  include Redis::Store::Ttl
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
        it 'must call set with key and value' do
          RedisWithTtl.any_instance.expects(:super).with(key, value)

          redis.set(key, value)
        end
      end

      describe 'with options' do
        it 'must call setex with proper expiry' do
          RedisWithTtl.any_instance.expects(:setex).with(key, options[:expire_after], value)

          redis.set(key, value, options)
        end
      end
    end

    describe '#setnx' do
      it 'must call setnx with key and value' do
        RedisWithTtl.any_instance.expects(:super).with(key, value)

        redis.setnx(key, value)
      end

      describe 'without options' do
        it 'must not call expire' do
          RedisWithTtl.any_instance.expects(:expire).never

          redis.setnx(key, value)
        end
      end

      describe 'with options' do
        it 'must call expire' do
          RedisWithTtl.any_instance.expects(:expire).with(key, options[:expire_after])

          redis.setnx(key, value, options)
        end
      end
    end
  end
end
