require 'test_helper'

describe Redis::Rails::VERSION do
  it "must be equal to 3.2.3" do
    Redis::Rails::VERSION.must_equal '3.2.3'
  end
end
