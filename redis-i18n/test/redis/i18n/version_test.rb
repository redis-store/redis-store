require 'test_helper'

describe Redis::I18n::VERSION do
  it "must be equal to 0.6.0.rc2" do
    Redis::I18n::VERSION.must_equal '0.6.0.rc2'
  end
end
