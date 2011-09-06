require 'bundler'
Bundler.setup
require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'

begin
  require 'rdoc/task'
rescue LoadError
  require 'rake/rdoctask'
end

task :default => 'test:suite'

namespace :test do
  desc "Run all the examples by starting a detached Redis instance"
  task :suite => :prepare do
    invoke_with_redis_replication 'test:run'
  end

  Rake::TestTask.new(:run) do |t|
    t.libs.push 'lib'
    t.test_files = FileList['test/**/*_test.rb']
    t.ruby_opts  = ["-I test"]
    t.verbose    = true
  end
end

task :prepare do
  `mkdir -p tmp/pids && rm tmp/*.rdb`
end

load 'tasks/redis.tasks.rb'
