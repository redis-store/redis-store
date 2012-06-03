require 'test_helper'

describe Redis::Rails::VERSION do
  it "must be equal to 3.1.5" do
    Redis::Rails::VERSION.must_equal '3.1.5'
  end
end
