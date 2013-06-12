# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis-rails/version"

Gem::Specification.new do |s|
  s.name        = "redis-rails"
  s.version     = Redis::Rails::VERSION
  s.authors     = ["Luca Guidi", "Matt Horan"]
  s.email       = ["me@lucaguidi.com"]
  s.homepage    = "http://jodosha.github.com/redis-store"
  s.summary     = %q{Redis for Ruby on Rails}
  s.description = %q{Redis for Ruby on Rails}

  s.rubyforge_project = "redis-rails"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'redis-store',         '~> 1.1.0'
  s.add_dependency 'redis-activesupport', '>= 3.2.3'
  s.add_dependency 'redis-actionpack',    '>= 3.2.3'

  s.add_development_dependency 'rake',     '~> 10'
  s.add_development_dependency 'bundler',  '~> 1.2'
  s.add_development_dependency 'mocha',    '~> 0.13.0'
  s.add_development_dependency 'minitest', '~> 4.3.1'
end
