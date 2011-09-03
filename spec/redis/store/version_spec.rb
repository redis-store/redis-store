require 'spec_helper'

describe Redis::Store::VERSION do
  it "should describe Redis::Store version" do
    Redis::Store::VERSION.should == "1.1.0"
  end
end
