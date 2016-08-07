require 'test_helper'

describe Redis::Store::VERSION do
  it 'returns current version' do
    Redis::Store::VERSION.wont_equal nil
  end
end
