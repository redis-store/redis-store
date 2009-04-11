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

      it "should write the data with expiration time" do
        @store.write "rabbit", @white_rabbit, :expires_in => 1.second
        @store.read("rabbit").should === @white_rabbit ; sleep 2
        @store.read("rabbit").should be_nil
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

      it "should delete matched data" do
        @store.delete_matched "rabb*"
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

      it "should clear the store" do
        @store.clear
        @store.instance_variable_get(:@data).keys("*").should be_empty
      end

      it "should return store stats" do
        @store.stats.should_not be_empty
      end

      it "should fetch data" do
        @store.fetch("rabbit").should == @rabbit
        @store.fetch("rab-a-dab").should be_nil
        @store.fetch("rab-a-dab") { "Flora de Cana" }
        @store.fetch("rab-a-dab").should === "Flora de Cana"
        @store.fetch("rabbit", :force => true).should be_nil # force cache miss
        @store.fetch("rabbit", :force => true, :expires_in => 1.second) { @white_rabbit }
        @store.fetch("rabbit").should === @white_rabbit ; sleep 2
        @store.fetch("rabbit").should be_nil
      end
    end
  end
end
