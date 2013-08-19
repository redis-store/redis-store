require 'test_helper'

describe Redis::Sinatra::VERSION do
  it 'returns current version' do
    Redis::Sinatra::VERSION.must_equal '1.4.0'
  end
end
