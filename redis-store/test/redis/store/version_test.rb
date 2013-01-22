require 'test_helper'

describe Redis::Store::VERSION do
  it "must be equal to 1.1.4" do
    Redis::Store::VERSION.must_equal '1.1.4'
  end
end
