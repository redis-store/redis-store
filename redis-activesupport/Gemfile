source 'https://rubygems.org'
gemspec

gem 'redis-store', '~> 1.1.0', path: '../redis-store'
gem 'i18n'

version = ENV["RAILS_VERSION"] || "4"

rails = case version
when "master"
  {:github => "rails/rails"}
else
  "~> #{version}.0"
end

gem "rails", rails
