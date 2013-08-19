require 'test_helper'

describe Redis::ActionPack::VERSION do
  it 'returns current version' do
    Redis::ActionPack::VERSION.must_equal '4.0.0'
  end
end
