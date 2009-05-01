require File.join(File.dirname(__FILE__), "/../../spec_helper")

module Rack
  module Session
    describe "Redis" do
      before(:each) do
        @app = lambda { |env| }
        @store = Rack::Session::Redis.new(@app)
      end

      it "should be kind of Abstract::ID" do
        @store.should be_kind_of(Abstract::ID)
      end

      it "should accept connection params" do
        store = instantiate_store
        store.instance_variable_get(:@db).should == 0
        store.host.should == "localhost"
        store.port.should == "6379"

        store = instantiate_store "store.com"
        store.host.should == "store.com"
        
        store = instantiate_store "store.com:6380"
        store.host.should == "store.com"
        store.port.should == "6380"

        store = instantiate_store "store.com:6380/23"
        store.instance_variable_get(:@db).should == 23
        store.host.should == "store.com"
        store.port.should == "6380"
      end
      
      private
        def instantiate_store(address = nil)
          Rack::Session::Redis.new(@app, :redis_server => address).pool
        end
    end
  end
end
