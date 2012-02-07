require 'test_helper'

describe Redis::Rack::Cache::VERSION do
  it "must be equal to 1.1.rc3" do
    Redis::Rack::Cache::VERSION.must_equal '1.1.rc3'
  end
end
