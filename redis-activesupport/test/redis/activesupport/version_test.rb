require 'test_helper'

describe Redis::ActiveSupport::VERSION do
  it "must be equal to 4.0.0" do
    Redis::ActiveSupport::VERSION.must_equal '4.0.0'
  end
end
