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

system('gem install bundler -v=1.1.rc --no-rdoc --no-ri')

builds = GEMS.inject({}) do |result, rubygem|
  Dir.chdir(rubygem) do
    result[rubygem] = system('bundle exec rake')
  end

  result
end

if builds.values.all? { |success| success }
  puts
  puts "Redis Store build SUCCESS"
  exit(true)
else
  puts
  puts "Redis Store build FAILED"
  puts "Failed gems: #{builds.map {|rubygem, success| rubygem if not success }.compact.join(', ')}"
  exit(false)
end