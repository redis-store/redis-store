require File.join(File.dirname(__FILE__), "/../spec_helper")

describe RedisStore::VERSION do
  it "should describe RedisStore version" do
    RedisStore::VERSION::STRING.should == "1.0.0.beta2"
  end
end
