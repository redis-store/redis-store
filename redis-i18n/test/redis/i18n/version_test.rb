require 'test_helper'

describe Redis::I18n::VERSION do
  it "must be equal to 0.6.1" do
    Redis::I18n::VERSION.must_equal '0.6.1'
  end
end
