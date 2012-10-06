require 'test_helper'

describe Redis::Store::VERSION do
  it "must be equal to 1.1.3" do
    Redis::Store::VERSION.must_equal '1.1.3'
  end
end
