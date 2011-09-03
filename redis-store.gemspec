# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis/store/version"

Gem::Specification.new do |s|
  s.name        = "redis-store"
  s.version     = Redis::Store::VERSION
  s.authors     = ["Luca Guidi"]
  s.email       = ["guidi.luca@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Redis backed stores for Ruby web frameworks}
  s.description = %q{Namespaced Rack::Session, Rack::Cache, I18n and cache Redis stores for Ruby web frameworks.}

  s.rubyforge_project = "redis-store"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_dependency(%q<redis>, ["~> 2.2.0"])
      s.add_development_dependency(%q<git>, ["~> 1.2.5"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.14"])
      s.add_development_dependency(%q<rake>, ["~> 0.9.1"])
      if RUBY_VERSION > '1.9'
        s.add_development_dependency(%q<ruby-debug19>, ["~> 0.11.6"])
      else
        s.add_development_dependency(%q<ruby-debug>, ["~> 0.10.4"])
        s.add_development_dependency(%q<minitest>)
      end
    else
      s.add_dependency(%q<redis>, ["~> 2.2.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.14"])
      s.add_dependency(%q<rake>, ["~> 0.9.1"])
      if RUBY_VERSION > '1.9'
        s.add_dependency(%q<ruby-debug19>, ["~> 0.11.6"])
      else
        s.add_dependency(%q<ruby-debug>, ["~> 0.10.4"])
        s.add_dependency(%q<minitest>)
      end
    end
  else
      s.add_dependency(%q<redis>, ["~> 2.2.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.14"])
      s.add_dependency(%q<rake>, ["~> 0.9.1"])
      if RUBY_VERSION > '1.9'
        s.add_dependency(%q<ruby-debug19>, ["~> 0.11.6"])
      else
        s.add_dependency(%q<ruby-debug>, ["~> 0.10.4"])
        s.add_dependency(%q<minitest>)
      end
  end
end

