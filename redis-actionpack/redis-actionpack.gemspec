# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis/actionpack/version"

Gem::Specification.new do |s|
  s.name        = "redis-actionpack"
  s.version     = Redis::ActionPack::VERSION
  s.authors     = ["Luca Guidi"]
  s.email       = ["guidi.luca@gmail.com"]
  s.homepage    = "http://jodosha.github.com/redis-store"
  s.summary     = %q{Redis session store for ActionPack}
  s.description = %q{Redis session store for ActionPack}

  s.rubyforge_project = "redis-actionpack"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'redis-store', '~> 1.1.0'
  s.add_runtime_dependency 'redis-rack',  '~> 1.4.0'
  s.add_runtime_dependency 'actionpack',  '~> 3.2.2'

  s.add_development_dependency 'rake',           '~> 0.9.2.2'
  s.add_development_dependency 'bundler',        '~> 1.1.rc'
  s.add_development_dependency 'minitest',       '~> 2.8.0'
  s.add_development_dependency 'purdytest',      '~> 1.0.0'
  s.add_development_dependency 'tzinfo'
  s.add_development_dependency 'mini_specunit'
  s.add_development_dependency 'mini_backtrace'
end
