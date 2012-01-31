require 'minitest/autorun'
require 'minitest/rails'
require 'active_support/core_ext/numeric/time'

ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

class MiniTest::Rails::IntegrationTest < MiniTest::Rails::Spec
  include ActiveSupport::Testing::SetupAndTeardown

  include ActionDispatch::Integration::Runner

  @@app = nil

  def self.app
    # DEPRECATE Rails application fallback
    # This should be set by the initializer
    @@app || (defined?(Rails.application) && Rails.application) || nil
  end

  def self.app=(app)
    @@app = app
  end

  def app
    super || self.class.app
  end
end
