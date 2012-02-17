require 'test_helper'

describe Redis::ActiveSupport::VERSION do
  it "must be equal to 3.2.1" do
    Redis::ActiveSupport::VERSION.must_equal '3.2.1'
  end
end
