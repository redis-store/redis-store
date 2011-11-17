#!/usr/bin/env ruby

GEMS = %w(
  redis-store
  redis-actionpack
  redis-activesupport
  redis-i18n
  redis-rack
  redis-rack-cache
  redis-rails
  redis-sinatra
).freeze

GEMS.each do |rubygem|
  Dir.chdir(rubygem) do
    system 'bundle'
    system 'bundle exec rake'
  end
end