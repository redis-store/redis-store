require 'test_helper'

describe "I18n::Backend::Redis" do
  def setup
    @backend     = I18n::Backend::Redis.new
    @store       = @backend.store
    I18n.backend = @backend
  end

  it "stores translations" do
    I18n.backend.store_translations :en, :foo => { :bar => :baz }
    I18n.t(:"foo.bar").must_equal(:baz)

    I18n.backend.store_translations :en, "foo" => { "bar" => "baz" }
    I18n.t(:"foo.bar").must_equal("baz")
  end

  it "gets translations" do
    I18n.backend.store_translations :en, :foo => { :bar => { :baz => :bang } }
    I18n.t(:"foo.bar.baz").must_equal(:bang)
    I18n.t(:"baz", :scope => :"foo.bar").must_equal(:bang)
  end

  it "gets translations with count" do
    I18n.backend.store_translations :en, :bar => { :one => :bar, :other => "%{count} bars" }
    I18n.t(:bar, :count => 1).must_equal(:bar)
    I18n.t(:bar, :count => 10).must_equal("10 bars")
  end

  it "raises an exception when a proc translation is being saved" do
    lambda {
      I18n.backend.store_translations :en, :foo => lambda {|| }
    }.must_raise RuntimeError
  end

  describe "available locales" do
    def setup
      @locales = [ :en, :it, :es, :fr, :de ]
    end

    it "returns values" do
      @locales.each { |locale| I18n.backend.store_translations locale, :foo => "bar" }
      available_locales = I18n.backend.available_locales

      @locales.each do |locale|
        available_locales.must_include(locale)
      end
    end

    it "returns right values when the store is namespaced" do
      I18n.backend = I18n::Backend::Redis.new :namespace => 'foo'

      @locales.each { |locale| I18n.backend.store_translations locale, :foo => "bar" }
      available_locales = I18n.backend.available_locales

      @locales.each do |locale|
        available_locales.must_include(locale)
      end
    end
  end
end

