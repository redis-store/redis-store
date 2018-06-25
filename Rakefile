require 'bundler/setup'
require 'rake'
require 'bundler/gem_tasks'
require 'redis-store/testing/tasks'
require 'appraisal'
require 'rubocop/rake_task'

RuboCop::RakeTask.new :lint

if !ENV["APPRAISAL_INITIALIZED"] && !ENV["TRAVIS"]
  task :default do
    sh "appraisal install && rake appraisal default"
  end
end
