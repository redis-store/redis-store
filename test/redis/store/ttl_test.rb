require 'test_helper'

class MockRedis
  def initialize
    @sets = []
    @setexes = []
    @setnxes = []
    @expires = []
  end

  def set(*a)
    @sets << a
  end

  def has_set?(*a)
    @sets.include?(a)
  end

  def setex(*a)
    @setexes << a
  end

  def has_setex?(*a)
    @setexes.include?(a)
  end

  def setnx(*a)
    @setnxes << a
  end

  def has_setnx?(*a)
    @setnxes.include?(a)
  end

  def multi(&block)
    instance_eval do
      def setnx(*a)
        @setnxes << a
      end

      block.call
    end
  end

  def expire(*a)
    @expires << a
  end

  def has_expire?(*a)
    @expires.include?(a)
  end

end

class MockTtlStore < MockRedis
  include Redis::Store::Ttl
end

describe MockTtlStore do
  let(:key) { 'hello' }
  let(:value) { 'value' }
  let(:options) { { :expire_after => 3600 } }
  let(:redis) { MockTtlStore.new }

  describe '#set' do
    describe 'without options' do
      it 'must call super with key and value' do
        redis.set(key, value)
        redis.has_set?(key, value).must_equal true
      end
    end

    describe 'with options' do
      it 'must call setex with proper expiry and set raw to true' do
        redis.set(key, value, options)
        redis.has_setex?(key, options[:expire_after], value, :raw => true).must_equal true
      end
    end
  end

  describe '#setnx' do
    describe 'without expiry' do
      it 'must call super with key and value' do
        redis.setnx(key, value)
        redis.has_setnx?(key, value)
      end

      it 'must not call expire' do
        MockTtlStore.any_instance.expects(:expire).never

        redis.setnx(key, value)
      end
    end

    describe 'with expiry' do
      it 'must call setnx with key and value and set raw to true' do
        redis.setnx(key, value, options)
        redis.has_setnx?(key, value, :raw => true).must_equal true
      end

      it 'must call expire' do
        redis.setnx(key, value, options)
        redis.has_expire?(key, options[:expire_after]).must_equal true
      end
    end
  end
end
