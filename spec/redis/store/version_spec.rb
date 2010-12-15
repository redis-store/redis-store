require 'spec_helper'

describe Redis::Store::VERSION do
  it "should describe Redis::Store version" do
    Redis::Store::VERSION::STRING.should == "1.0.0.beta4"
  end
end
