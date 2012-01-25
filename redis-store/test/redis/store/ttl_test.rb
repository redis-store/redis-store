require 'test_helper'

class RedisWithTtl < Redis
  include Redis::Store::Ttl
end

describe RedisWithTtl do
  describe 'an instance' do
    let(:key) { 'hello' }
    let(:value) { 'value' }
    let(:options) { { :expire_after => 3600 } }

    before do
      @r = RedisWithTtl.new
    end

    it 'must respond to set' do
      @r.must_respond_to(:set)
    end

    it 'must respond to setnx' do
      @r.must_respond_to(:setnx)
    end

    describe '#set' do
      describe 'without options' do
        it 'must call set with key and value' do
          RedisWithTtl.any_instance.expects(:super).with(key, value)

          @r.set(key, value)
        end
      end

      describe 'with options' do
        it 'must call setex with proper expiry' do
          RedisWithTtl.any_instance.expects(:setex).with(key, 3600, value)

          @r.set(key, value, options)
        end
      end
    end

    describe '#setnx' do
      it 'must call setnx with key and value' do
        RedisWithTtl.any_instance.expects(:super).with(key, value)

        @r.setnx(key, value)
      end

      describe 'without options' do
        it 'must not call expire' do
          RedisWithTtl.any_instance.expects(:expire).never

          @r.setnx(key, value)
        end
      end

      describe 'with options' do
        it 'must call expire' do
          RedisWithTtl.any_instance.expects(:expire).with(key, 3600)

          @r.setnx(key, value, options)
        end
      end
    end
  end
end
