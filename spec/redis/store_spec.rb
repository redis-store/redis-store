require 'spec_helper'

describe "Redis::Store" do
  before :each do
    @store = Redis::Store.new
  end

  it "should force reconnection" do
    client = @store.instance_variable_get(:@client)
    client.should_receive(:reconnect)
    @store.reconnect
  end
end
