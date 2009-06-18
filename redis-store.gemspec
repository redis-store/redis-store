Gem::Specification.new do |s|
  s.name               = "redis-store"
  s.version            = "0.3.6"
  s.date               = "2009-06-18"
  s.summary            = "Rack::Session, Rack::Cache and cache Redis stores for Ruby web frameworks."
  s.author             = "Luca Guidi"
  s.email              = "guidi.luca@gmail.com"
  s.homepage           = "http://lucaguidi.com"
  s.description        = "Rack::Session, Rack::Cache and cache Redis stores for Ruby web frameworks."
  s.has_rdoc           = true
  s.files              = ["MIT-LICENSE", "README.textile", "Rakefile", "lib/cache/merb/redis_store.rb", "lib/cache/rails/redis_store.rb", "lib/cache/sinatra/redis_store.rb", "lib/rack/cache/redis_entitystore.rb", "lib/rack/cache/redis_metastore.rb", "lib/rack/session/merb.rb", "lib/rack/session/redis.rb", "lib/redis-store.rb", "lib/redis/distributed_marshaled_redis.rb", "lib/redis/marshaled_redis.rb", "lib/redis/redis_factory.rb", "redis-store.gemspec", "spec/cache/merb/redis_store_spec.rb", "spec/cache/rails/redis_store_spec.rb", "spec/cache/sinatra/redis_store_spec.rb", "spec/config/master.conf", "spec/config/single.conf", "spec/config/slave.conf", "spec/rack/cache/entitystore/pony.jpg", "spec/rack/cache/entitystore/redis_spec.rb", "spec/rack/cache/metastore/redis_spec.rb", "spec/rack/session/redis_spec.rb", "spec/redis/distributed_marshaled_redis_spec.rb", "spec/redis/marshaled_redis_spec.rb", "spec/redis/redis_factory_spec.rb", "spec/spec_helper.rb"]
  s.test_files         = ["spec/cache/merb/redis_store_spec.rb", "spec/cache/rails/redis_store_spec.rb", "spec/cache/sinatra/redis_store_spec.rb", "spec/rack/cache/entitystore/redis_spec.rb", "spec/rack/cache/metastore/redis_spec.rb", "spec/rack/session/redis_spec.rb", "spec/redis/distributed_marshaled_redis_spec.rb", "spec/redis/marshaled_redis_spec.rb", "spec/redis/redis_factory_spec.rb"]
  s.extra_rdoc_files   = ["README.textile"]
end
