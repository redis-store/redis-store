require 'test_helper'

describe Redis::Store do
  before do
    @store = Redis::Store.new
  end

  it "returns useful informations about the server"
  it "must force reconnection"
end