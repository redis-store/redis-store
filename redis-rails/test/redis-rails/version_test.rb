require 'test_helper'

describe Redis::Rails::VERSION do
  it "must be equal to 3.1.3.rc4" do
    Redis::Rails::VERSION.must_equal '3.1.3.rc4'
  end
end
