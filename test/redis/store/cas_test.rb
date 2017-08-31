require 'test_helper'

describe "Redis::Store::Cas" do
  def setup
    @store  = Redis::Store.new :namespace => 'storetest'
  end

  def teardown
    @store.flushdb
    @store.quit
  end

  def test_cas
    @store.set('foo', 'baz')
    assert(@store.cas('foo') do |value|
      assert_equal 'baz', value
      'bar'
    end)
    assert_equal 'bar', @store.get('foo')
  end

  def test_cas_with_cache_miss
    refute @store.cas('not_exist') { |_value| flunk }
  end

  def test_cas_with_conflict
    @store.set('foo', 'bar')
    refute @store.cas('foo') { |_value|
      @store.set('foo', 'baz')
      'biz'
    }
    assert_equal 'baz', @store.get('foo')
  end

  # TODO write a Mockup redis with support for watch
  def test_cas_with_ttl
    @store.set('ttlfoo','bar')
    assert(@store.cas('ttlfoo',3600) do |value|
      assert_equal 'bar',value
      'ttlbar'
    end)
    assert_equal @store.get('ttlfoo'),'ttlbar'
    assert @store.ttl('ttlfoo') > 0
    assert(@store.cas('ttlfoo') do |value|
      'bar'
    end)
    assert_equal -1,@store.ttl('ttlfoo')
  end

  def test_cas_multi_with_empty_set
    refute @store.cas_multi { |_hash| flunk }
  end


  def test_read_multi
    @store.set('k1','m1')
    @store.set('k2','m2')
    assert_equal({"k1" => "m1","k2" => "m2"},@store.read_multi("k1","k2"))
  end

  def test_cas_multi
    @store.set('foo', 'bar')
    @store.set('fud', 'biz')
    assert_equal true, (@store.cas_multi('foo', 'fud') do |hash|
      assert_equal({ "foo" => "bar", "fud" => "biz" }, hash)
      { "foo" => "baz", "fud" => "buz" }
    end)
    assert_equal({ "foo" => "baz", "fud" => "buz" }, @store.read_multi('foo', 'fud'))
  end

  def test_cas_multi_with_ttl
    @store.set('foo', 'bar')
    @store.set('fud', 'biz')
    @store.cas_multi('foo','fud',{:expires_in => 3600}) do |hash|
      { "foo" => "baz", "fud" => "buz" }
    end
    assert @store.ttl('foo') > 0
    assert @store.ttl('fud') > 0
  end

  def test_cas_multi_with_cache_miss
    assert(@store.cas_multi('not_exist') do |hash|
      assert hash.empty?
      {}
    end)
  end

  def test_cas_multi_with_altered_key
    @store.set('foo', 'baz')
    assert @store.cas_multi('foo') { |_hash| { 'fu' => 'baz' } }
    assert_nil @store.get('fu')
    assert_equal 'baz', @store.get('foo')
  end

  def test_cas_multi_with_partial_miss
    @store.set('foo', 'baz')
    assert(@store.cas_multi('foo', 'bar') do |hash|
      assert_equal({ "foo" => "baz" }, hash)
      {}
    end)
    assert_equal 'baz', @store.get('foo')
  end

  def test_cas_multi_with_partial_update
    @store.set('foo', 'bar')
    @store.set('fud', 'biz')
    assert(@store.cas_multi('foo', 'fud') do |hash|
      assert_equal({ "foo" => "bar", "fud" => "biz" }, hash)

      { "foo" => "baz" }
    end)
    assert_equal({ "foo" => "baz", "fud" => "biz" }, @store.read_multi('foo', 'fud'))
  end

  def test_cas_multi_with_partial_conflict
    @store.set('foo', 'bar')
    @store.set('fud', 'biz')
    result = @store.cas_multi('foo', 'fud') do |hash|
      assert_equal({ "foo" => "bar", "fud" => "biz" }, hash)
      @store.set('foo', 'bad')
      { "foo" => "baz", "fud" => "buz" }
    end
    assert result
    assert_equal({ "foo" => "bad", "fud" => "buz" }, @store.read_multi('foo', 'fud'))
  end

end
