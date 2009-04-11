require File.join(File.dirname(__FILE__), "/../../spec_helper")

module ActiveSupport
  module Cache
    describe "RedisStore" do
      before(:each) do
        @store  = RedisStore.new
        @rabbit = OpenStruct.new :name => "bunny"
        @white_rabbit = OpenStruct.new :color => "white"
        @store.write "rabbit", @rabbit
      end

      it "should read the data" do
        @store.read("rabbit").should === @rabbit
      end
      
      it "should write the data" do
        @store.write "rabbit", @white_rabbit
        @store.read("rabbit").should === @white_rabbit
      end
      
      it "should read raw data" do
        @store.read("rabbit", :raw => true).should == "\004\bU:\017OpenStruct{\006:\tname\"\nbunny"
      end
      
      it "should write raw data" do
        @store.write "rabbit", @white_rabbit, :raw => true
        @store.read("rabbit", :raw => true).should == %(#<OpenStruct color="white">)
      end
    end
  end
end
