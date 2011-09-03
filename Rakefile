$:.unshift 'lib'
require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'bundler/gem_tasks'

task :default => "spec:suite"

namespace :spec do
  desc "Run all the examples by starting a detached Redis instance"
  task :suite => :prepare do
    invoke_with_redis_replication "spec:run"
  end

  Spec::Rake::SpecTask.new(:run) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = %w(-fs --color)
  end
end

desc "Run all examples with RCov"
task :rcov => :prepare do
  invoke_with_redis_replication "rcov_run"
end

Spec::Rake::SpecTask.new(:rcov_run) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
end

task :prepare do
  `mkdir -p tmp && rm tmp/*.rdb`
end

namespace :bundle do
  task :clean do
    system "rm -rf ~/.bundle/ ~/.gem/ .bundle/ Gemfile.lock"
  end
end

load "tasks/redis.tasks.rb"
