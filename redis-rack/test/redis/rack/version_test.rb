require 'test_helper'

describe Redis::Rack::VERSION do
  it "must be equal to 1.3.6" do
    Redis::Rack::VERSION.must_equal '1.3.6'
  end
end
