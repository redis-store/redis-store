require 'test_helper'

describe Redis::Rails::VERSION do
  it 'returns current version' do
    Redis::Rails::VERSION.must_equal '4.0.0'
  end
end
