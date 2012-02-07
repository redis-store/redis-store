require 'test_helper'

describe Redis::Sinatra::VERSION do
  it "must be equal to 1.3.1.rc2" do
    Redis::Sinatra::VERSION.must_equal '1.3.1.rc2'
  end
end
