require 'bundler'
Bundler.setup
require 'rake'
require 'bundler/gem_tasks'

load 'tasks/redis.tasks.rb'
task :default => 'redis:test:suite'
