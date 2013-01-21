require 'test_helper'

describe Redis::ActionPack::VERSION do
  it "must be equal to 3.2.11" do
    Redis::ActionPack::VERSION.must_equal '3.2.11'
  end
end
