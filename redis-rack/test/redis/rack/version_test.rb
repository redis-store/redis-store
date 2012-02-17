require 'test_helper'

describe Redis::Rack::VERSION do
  it "must be equal to 1.4.1" do
    Redis::Rack::VERSION.must_equal '1.4.1'
  end
end
