require 'spec_helper'

module ActiveSupport
  module Cache
    describe RedisStore do
      before :each do
        @store  = ActiveSupport::Cache::RedisStore.new
        @dstore = ActiveSupport::Cache::RedisStore.new "redis://127.0.0.1:6380/1", "redis://127.0.0.1:6381/1"
        @rabbit = OpenStruct.new :name => "bunny"
        @white_rabbit = OpenStruct.new :color => "white"
        with_store_management do |store|
          store.write "rabbit", @rabbit
          store.delete "counter"
          store.delete "rub-a-dub"
        end
      end

      it "should accept connection params" do
        redis = instantiate_store
        redis.to_s.should == "Redis Client connected to 127.0.0.1:6379 against DB 0"

        redis = instantiate_store "redis://127.0.0.1"
        redis.to_s.should == "Redis Client connected to 127.0.0.1:6379 against DB 0"

        redis = instantiate_store "redis://127.0.0.1:6380"
        redis.to_s.should == "Redis Client connected to 127.0.0.1:6380 against DB 0"

        redis = instantiate_store "redis://127.0.0.1:6380/13"
        redis.to_s.should == "Redis Client connected to 127.0.0.1:6380 against DB 13"

        redis = instantiate_store "redis://127.0.0.1:6380/13/theplaylist"
        redis.to_s.should == "Redis Client connected to 127.0.0.1:6380 against DB 13 with namespace theplaylist"
      end

      it "should instantiate a ring" do
        store = instantiate_store
        store.should be_kind_of(Redis::Store)
        store = instantiate_store ["redis://127.0.0.1:6379/0", "redis://127.0.0.1:6379/1"]
        store.should be_kind_of(Redis::DistributedStore)
      end

      it "should read the data" do
        with_store_management do |store|
          store.read("rabbit").should === @rabbit
        end
      end

      it "should write the data" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit
          store.read("rabbit").should === @white_rabbit
        end
      end

      it "should write the data with expiration time" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit, :expires_in => 1.second
          store.read("rabbit").should == @white_rabbit ; sleep 2
          store.read("rabbit").should be_nil
        end
      end

      it "should not write data if :unless_exist option is true" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit, :unless_exist => true
          store.read("rabbit").should == @rabbit
        end
      end

      if ::Redis::Store.rails3?
        if RUBY_VERSION.match /1\.9/
          it "should read raw data" do
            with_store_management do |store|
              result = store.read("rabbit", :raw => true)
              result.should include("ActiveSupport::Cache::Entry")
              result.should include("\x0FOpenStruct{\x06:\tnameI\"\nbunny\x06:\x06EF")
            end
          end
        else
          it "should read raw data" do
            with_store_management do |store|
              result = store.read("rabbit", :raw => true)
              result.should include("ActiveSupport::Cache::Entry")
              result.should include("\017OpenStruct{\006:\tname\"\nbunny")
            end
          end
        end

        it "should write raw data" do
          with_store_management do |store|
            store.write "rabbit", @white_rabbit, :raw => true
            store.read("rabbit", :raw => true).should include("ActiveSupport::Cache::Entry")
          end
        end
      else
        it "should read raw data" do
          with_store_management do |store|
            store.read("rabbit", :raw => true).should == Marshal.dump(@rabbit)
          end
        end

        it "should write raw data" do
          with_store_management do |store|
            store.write "rabbit", @white_rabbit, :raw => true
            store.read("rabbit", :raw => true).should == %(#<OpenStruct color="white">)
          end
        end
      end

      it "should delete data" do
        with_store_management do |store|
          store.delete "rabbit"
          store.read("rabbit").should be_nil
        end
      end

      it "should delete matched data" do
        with_store_management do |store|
          store.delete_matched "rabb*"
          store.read("rabbit").should be_nil
        end
      end

      it "should verify existence of an object in the store" do
        with_store_management do |store|
          store.exist?("rabbit").should be_true
          store.exist?("rab-a-dub").should be_false
        end
      end

      it "should increment a key" do
        with_store_management do |store|
          3.times { store.increment "counter" }
          store.read("counter", :raw => true).to_i.should == 3
        end
      end

      it "should decrement a key" do
        with_store_management do |store|
          3.times { store.increment "counter" }
          2.times { store.decrement "counter" }
          store.read("counter", :raw => true).to_i.should == 1
        end
      end

      it "should increment a key by given value" do
        with_store_management do |store|
          store.increment "counter", 3
          store.read("counter", :raw => true).to_i.should == 3
        end
      end

      it "should decrement a key by given value" do
        with_store_management do |store|
          3.times { store.increment "counter" }
          store.decrement "counter", 2
          store.read("counter", :raw => true).to_i.should == 1
        end
      end

      it "should clear the store" do
        with_store_management do |store|
          store.clear
          store.instance_variable_get(:@data).keys("*").flatten.should be_empty
        end
      end

      it "should return store stats" do
        with_store_management do |store|
          store.stats.should_not be_empty
        end
      end

      it "should fetch data" do
        with_store_management do |store|
          store.fetch("rabbit").should == @rabbit
          store.fetch("rub-a-dub").should be_nil
          store.fetch("rub-a-dub") { "Flora de Cana" }
          store.fetch("rub-a-dub").should === "Flora de Cana"
          store.fetch("rabbit", :force => true) # force cache miss
          store.fetch("rabbit", :force => true, :expires_in => 1.second) { @white_rabbit }
          store.fetch("rabbit").should == @white_rabbit
          sleep 2
          store.fetch("rabbit").should be_nil
        end
      end

      if ::Redis::Store.rails3?
        it "should read multiple keys" do
          @store.write "irish whisky", "Jameson"
          rabbit, whisky = @store.read_multi "rabbit", "irish whisky"
          rabbit.raw_value.should === @rabbit
          whisky.raw_value.should == "Jameson"
        end
      else
        it "should read multiple keys" do
          @store.write "irish whisky", "Jameson"
          rabbit, whisky  = @store.read_multi "rabbit", "irish whisky"
          rabbit.should === @rabbit
          whisky.should  == "Jameson"
        end
      end

      describe "namespace" do
        before :each do
          @namespace = "theplaylist"
          @store = ActiveSupport::Cache::RedisStore.new :namespace => @namespace
          @data = @store.instance_variable_get(:@data)
          @client = @data.instance_variable_get(:@client)
        end

        it "should read the data" do
          @client.should_receive(:call).with(:get, "#{@namespace}:rabbit")
          @store.read("rabbit")
        end

        if ::Redis::Store.rails3?
          # it "should write the data"
          # it "should write the data" do
          #   @data.should_receive(:set).with("#{@namespace}:rabbit"), Marshal.dump(ActiveSupport::Cache::Entry.new(@white_rabbit)))
          #   @store.write "rabbit", @white_rabbit
          # end
        else
          it "should write the data" do
            @client.should_receive(:call).with(:set, "#{@namespace}:rabbit", Marshal.dump(@white_rabbit))
            @store.write "rabbit", @white_rabbit
          end
        end

        it "should delete the data" do
          @client.should_receive(:call).with(:del, "#{@namespace}:rabbit")
          @store.delete "rabbit"
        end

        it "should delete matched data" do
          @client.should_receive(:call).with(:del, "#{@namespace}:rabbit")
          @client.should_receive(:call).with(:keys, "theplaylist:rabb*").and_return [ "#{@namespace}:rabbit" ]
          @store.delete_matched "rabb*"
        end

        if ::Redis::Store.rails3?
          it "should verify existence of an object in the store" do
            @client.should_receive(:call).with(:get, "#{@namespace}:rabbit")
            @store.exist?("rabbit")
          end
        else
          it "should verify existence of an object in the store" do
            @client.should_receive(:call).with(:exists, "#{@namespace}:rabbit")
            @store.exist?("rabbit")
          end
        end

        it "should increment a key" do
          @client.should_receive(:call).with(:incrby, "#{@namespace}:counter", 1)
          @store.increment "counter"
        end

        it "should decrement a key" do
          @client.should_receive(:call).with(:decrby, "#{@namespace}:counter", 1)
          @store.decrement "counter"
        end

        it "should fetch data" do
          @client.should_receive(:call).with(:get, "#{@namespace}:rabbit")
          @store.fetch "rabbit"
        end

        it "should read multiple keys" do
          rabbits = [ Marshal.dump(@rabbit), Marshal.dump(@white_rabbit) ]
          @client.should_receive(:call).with(:mget, "#{@namespace}:rabbit", "#{@namespace}:white_rabbit").and_return rabbits
          @store.read_multi "rabbit", "white_rabbit"
        end
      end

      if ::Redis::Store.rails3?
        describe "notifications" do
          it "should notify on #fetch" do
            with_notifications do
              @store.fetch("radiohead") { "House Of Cards" }
            end

            read, generate, write = @events
            read.name.should        == "cache_read.active_support"
            read.payload.should     == { :key => "radiohead", :super_operation => :fetch }
            generate.name.should    == "cache_generate.active_support"
            generate.payload.should == { :key => "radiohead" }
            write.name.should       == "cache_write.active_support"
            write.payload.should    == { :key => "radiohead" }
          end

          it "should notify on #read" do
            with_notifications do
              @store.read "metallica"
            end

            read = @events.first
            read.name.should    == "cache_read.active_support"
            read.payload.should == { :key => "metallica", :hit => false }
          end

          # it "should notify on #read_multi" # Not supported in Rails 3

          it "should notify on #write" do
            with_notifications do
              @store.write "depeche mode", "Enjoy The Silence"
            end

            write = @events.first
            write.name.should    == "cache_write.active_support"
            write.payload.should == { :key => "depeche mode" }
          end

          it "should notify on #delete" do
            with_notifications do
              @store.delete "the new cardigans"
            end

            delete = @events.first
            delete.name.should    == "cache_delete.active_support"
            delete.payload.should == { :key => "the new cardigans" }
          end

          it "should notify on #exist?" do
            with_notifications do
              @store.exist? "the smiths"
            end

            exist = @events.first
            exist.name.should    == "cache_exist?.active_support"
            exist.payload.should == { :key => "the smiths" }
          end

          it "should notify on #delete_matched" do
            with_notifications do
              @store.delete_matched "afterhours*"
            end

            delete_matched = @events.first
            delete_matched.name.should    == "cache_delete_matched.active_support"
            delete_matched.payload.should == { :key => %("afterhours*") }
          end

          it "should notify on #increment" do
            with_notifications do
              @store.increment "pearl jam"
            end

            increment = @events.first
            increment.name.should    == "cache_increment.active_support"
            increment.payload.should == { :key => "pearl jam", :amount => 1 }
          end

          it "should notify on #decrement" do
            with_notifications do
              @store.decrement "placebo"
            end

            decrement = @events.first
            decrement.name.should    == "cache_decrement.active_support"
            decrement.payload.should == { :key => "placebo", :amount => 1 }
          end

          # it "should notify on cleanup" # TODO implement in ActiveSupport::Cache::RedisStore

          it "should notify on clear" do
            with_notifications do
              @store.clear
            end

            clear = @events.first
            clear.name.should    == "cache_clear.active_support"
            clear.payload.should == { :key => nil }
          end
        end
      end

      private
        def instantiate_store(addresses = nil)
          ActiveSupport::Cache::RedisStore.new(addresses).instance_variable_get(:@data)
        end

        def with_store_management
          yield @store
          yield @dstore
        end

        def with_notifications
          @events = [ ]
          ActiveSupport::Cache::RedisStore.instrument = true
          ActiveSupport::Notifications.subscribe(/^cache_(.*)\.active_support$/) do |*args|
            @events << ActiveSupport::Notifications::Event.new(*args)
          end
          yield
          ActiveSupport::Cache::RedisStore.instrument = false
        end
    end
  end
end
