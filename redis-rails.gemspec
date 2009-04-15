Gem::Specification.new do |s|
  s.name               = "redis-rails"
  s.version            = "0.0.2"
  s.date               = "2009-04-16"
  s.summary            = "Redis store for Rails"
  s.author             = "Luca Guidi"
  s.email              = "guidi.luca@gmail.com"
  s.homepage           = "http://lucaguidi.com"
  s.description        = "Redis store for Rails"
  s.has_rdoc           = true
  s.files              = ["MIT-LICENSE", "README.textile", "Rakefile", "lib/active_support/cache/redis_store.rb", "lib/redis-rails.rb", "lib/redis/distributed_marshaled_redis.rb", "lib/redis/marshaled_redis.rb", "redis-rails.gemspec", "spec/active_support/cache/redis_store_spec.rb", "spec/config/master.conf", "spec/config/single.conf", "spec/config/slave.conf", "spec/redis/distributed_marshaled_redis_spec.rb", "spec/redis/marshaled_redis_spec.rb", "spec/spec_helper.rb"]
  s.test_files         = ["spec/active_support/cache/redis_store_spec.rb", "spec/redis/distributed_marshaled_redis_spec.rb", "spec/redis/marshaled_redis_spec.rb"]
  s.extra_rdoc_files   = ["README.textile"]
end
