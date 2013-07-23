require 'test_helper'

describe Redis::Rails::VERSION do
  it "must be equal to 4.0.0" do
    Redis::Rails::VERSION.must_equal '4.0.0'
  end
end
