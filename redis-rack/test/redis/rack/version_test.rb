require 'test_helper'

describe Redis::Rack::VERSION do
  it 'returns current version' do
    Redis::Rack::VERSION.must_equal '1.5.0'
  end
end
