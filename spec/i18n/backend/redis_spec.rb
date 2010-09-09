require 'spec_helper'

describe "I18n::Backend::Redis" do
  before :each do
    @backend     = I18n::Backend::Redis.new
    @store       = @backend.store
    I18n.backend = @backend
  end

  it "should instantiate a store" do
    @store.should be_kind_of(Redis::Store)
  end

  it "should instantiate a distributed store" do
    store = I18n::Backend::Redis.new([ "redis://127.0.0.1:6379", "redis://127.0.0.1:6380" ]).store
    store.should be_kind_of(Redis::DistributedStore)
  end

  it "should accept string uri" do
    store = I18n::Backend::Redis.new("redis://127.0.0.1:6380/13/theplaylist").store
    store.to_s.should == "Redis Client connected to 127.0.0.1:6380 against DB 13 with namespace theplaylist"
  end

  it "should accept hash params" do
    store = I18n::Backend::Redis.new(:host => "127.0.0.1", :port => "6380", :db =>"13", :namespace => "theplaylist").store
    store.to_s.should == "Redis Client connected to 127.0.0.1:6380 against DB 13 with namespace theplaylist"
  end

  it "should store translations" do
    I18n.backend.store_translations :en, :foo => { :bar => :baz }
    I18n.t(:"foo.bar").should == :baz

    I18n.backend.store_translations :en, "foo" => { "bar" => "baz" }
    I18n.t(:"foo.bar").should == "baz"
  end

  it "should get translations" do
    I18n.backend.store_translations :en, :foo => { :bar => { :baz => :bang } }
    I18n.t(:"foo.bar.baz").should == :bang
    I18n.t(:"baz", :scope => :"foo.bar").should == :bang
  end

  it "should not store proc translations" do
    lambda { I18n.backend.store_translations :en, :foo => lambda {|| } }.should raise_error("Key-value stores cannot handle procs")
  end

  it "should list available locales" do
    locales = [ :en, :it, :es, :fr, :de ]
    locales.each { |locale| I18n.backend.store_translations locale, :foo => "bar" }
    available_locales = I18n.backend.available_locales

    locales.each do |locale|
      available_locales.should include(locale)
    end
  end
end
