require 'test_helper'

describe Redis::ActiveSupport::VERSION do
  it "must be equal to 3.1.5" do
    Redis::ActiveSupport::VERSION.must_equal '3.1.5'
  end
end
