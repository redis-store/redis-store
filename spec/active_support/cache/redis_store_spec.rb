require File.join(File.dirname(__FILE__), "/../../spec_helper")

module ActiveSupport
  module Cache
    describe "RedisStore" do
      before(:each) do
        @store  = RedisStore.new
        @rabbit = OpenStruct.new :name => "bunny"
        @white_rabbit = OpenStruct.new :color => "white"
        @store.write  "rabbit", @rabbit
        @store.delete "counter"
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

      it "should delete data" do
        @store.delete "rabbit"
        @store.read("rabbit").should be_nil
      end

      it "should verify existence of an object in the store" do
        @store.exist?("rabbit").should be_true
        @store.exist?("rab-a-dub").should be_false
      end

      it "should increment a key" do
        3.times { @store.increment "counter" }
        @store.read("counter", :raw => true).to_i.should == 3
      end

      it "should decrement a key" do
        3.times { @store.increment "counter" }
        2.times { @store.decrement "counter" }
        @store.read("counter", :raw => true).to_i.should == 1
      end

      it "should increment a key by given value" do
        @store.increment "counter", 3
        @store.read("counter", :raw => true).to_i.should == 3
      end

      it "should decrement a key by given value" do
        3.times { @store.increment "counter" }
        @store.decrement "counter", 2
        @store.read("counter", :raw => true).to_i.should == 1
      end
    end
  end
end
