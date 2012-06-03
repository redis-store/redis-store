require 'test_helper'

describe Redis::ActionPack::VERSION do
  it "must be equal to 3.1.5" do
    Redis::ActionPack::VERSION.must_equal '3.1.5'
  end
end
