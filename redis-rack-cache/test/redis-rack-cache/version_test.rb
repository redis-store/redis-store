require 'test_helper'

describe Redis::Rack::Cache::VERSION do
  it 'returns current version' do
    Redis::Rack::Cache::VERSION.must_equal '1.2.2'
  end
end
