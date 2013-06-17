require 'test_helper'

describe ActiveSupport::Cache::RedisStore::KeyName do

  def subject 
    ActiveSupport::Cache::RedisStore::KeyName
  end

  it 'matches with start' do 
    key = subject.new 'foo*baz'
    key.is_matcher?.must_equal true
  end

  it 'does not match with star escaped' do 
    key = subject.new 'foo\*bar'
    key.is_matcher?.must_equal false
  end

  it 'does match with question mark' do 
    key = subject.new 'foo?baz'
    key.is_matcher?.must_equal true
  end

  it 'does not match with escaped question mark' do 
    key = subject.new 'foo\?baz'
    key.is_matcher?.must_equal false
  end

  it 'does match with square brackets' do 
    key = subject.new 'foo[baz]'
    key.is_matcher?.must_equal true
  end

  it 'does not match with escaped square brackets' do 
    key = subject.new 'foo\[baz\]'
    key.is_matcher?.must_equal false
  end
 
end
