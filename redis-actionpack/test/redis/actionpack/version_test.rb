require 'test_helper'

describe Redis::ActionPack::VERSION do
  it "must be equal to 4.0.0" do
    Redis::ActionPack::VERSION.must_equal '4.0.0'
  end
end
