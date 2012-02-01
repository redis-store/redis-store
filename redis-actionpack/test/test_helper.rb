require 'minitest/autorun'
require 'minitest/rails'
require 'active_support/core_ext/numeric/time'

ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# TODO: remove once https://github.com/blowmage/minitest-rails/issues/12 is resolved
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

def with_autoload_path(path)
  path = File.join(File.dirname(__FILE__), "fixtures", path)
  if ActiveSupport::Dependencies.autoload_paths.include?(path)
    yield
  else
    begin
      ActiveSupport::Dependencies.autoload_paths << path
      yield
    ensure
      ActiveSupport::Dependencies.autoload_paths.reject! {|p| p == path}
      ActiveSupport::Dependencies.clear
    end
  end
end
