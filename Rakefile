$:.unshift 'lib'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

REDIS_STORE_VERSION = "0.3.6"

task :default => :spec

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = "redis-store"
    gemspec.summary     = "Rack::Session, Rack::Cache and cache Redis stores for Ruby web frameworks."
    gemspec.description = "Rack::Session, Rack::Cache and cache Redis stores for Ruby web frameworks."
    gemspec.email       = "guidi.luca@gmail.com"
    gemspec.homepage    = "http://github.com/jodosha/redis-store"
    gemspec.authors     = [ "Luca Guidi" ]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler" 
end

desc 'Build and install the gem (useful for development purposes).'
task :install do
  system "gem build redis-store.gemspec"
  system "sudo gem uninstall redis-store"
  system "sudo gem install --local --no-rdoc --no-ri redis-store-#{REDIS_STORE_VERSION}.gem"
  system "rm redis-store-*.gem"
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = %w(-fs --color)
end

desc 'Show the file list for the gemspec file'
task :files do
  puts "Files:\n #{Dir['**/*'].reject {|f| File.directory?(f)}.sort.inspect}"
  puts "Test files:\n #{Dir['spec/**/*_spec.rb'].reject {|f| File.directory?(f)}.sort.inspect}"
end

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
end

load "tasks/redis.tasks.rb"

