# Rack::Session, Rack::Cache and cache Redis stores for Ruby web frameworks

## Installation

Download and install Redis from [http://code.google.com/p/redis/](http://code.google.com/p/redis/)

    curl -OL http://redis.googlecode.com/files/redis-1.02.tar.gz
    tar -zxvf redis-1.02.tar.gz
    mv redis-1.02 redis
    cd redis
    make

Install the gems

    sudo gem install redis-rb redis-store

## Cache store

Provides a cache store for your Ruby web framework of choice.

### Rails

    config.gem "redis-store", :source => "http://gemcutter.org", :lib => "redis-store"
    require "redis-store"
    config.cache_store = :redis_store

### Merb

    dependency "redis-store", "0.3.7"
    dependency("merb-cache", merb_gems_version) do
      Merb::Cache.setup do
        register(:redis, Merb::Cache::RedisStore, :servers => ["127.0.0.1:6379"])
      end
    end

### Sinatra

    require "sinatra"
    require "redis-store"
    class MyApp < Sinatra::Base
      register Sinatra::Cache
      get "/hi" do
        cache.fetch("greet") { "Hello, World!" }
      end
    end

## Rack::Session

Provides a Redis store for Rack::Session. See [http://rack.rubyforge.org/doc/Rack/Session.html](http://rack.rubyforge.org/doc/Rack/Session.html)

### Rack application

    require "rack"
    require "redis-store"
    require "application"
    use Rack::Session::Redis
    run Application.new

### Rails

    config.gem "redis-store", :source => "http://gemcutter.org", :lib => "redis-store"
    ActionController::Base.session_store = Rack::Session::Redis

### Merb

    dependency "redis-store", "0.3.7"
    Merb::Config.use do |c|
      c[:session_store] = "redis"
    end
    Merb::BootLoader.before_app_loads do
      Merb::SessionContainer.subclasses << "Merb::RedisSession"
    end

### Sinatra

Sorry, but Sinatra application boot system [hardcode](http://github.com/sinatra/sinatra/blob/0f02bafe86f8dd9bba9ab425468cb1067caa83ff/lib/sinatra/base.rb#L785) `Rack::Session::Cookie`

## Rack::Cache

Provides a Redis store for HTTP caching. See [http://github.com/rtomayko/rack-cache](http://github.com/rtomayko/rack-cache)

    require "rack"
    require "rack/cache"
    require "redis-store"
    require "application"
    use Rack::Cache,
      :metastore   => 'redis://localhost:6379/0',
      :entitystore => 'redis://localhost:6380/1'
    run Application.new

## Running specs

    gem install jeweler bundler
    git clone git://github.com/jodosha/redis-store.git
    cd redis-store
    gem bundle
    rake dtach:install
    rake redis:install
    rake

If you are on **Snow Leopard** you have to run `env ARCHFLAGS="-arch x86_64" gem bundle`

## Copyright

(c) 2009 Luca Guidi - [http://lucaguidi.com](http://lucaguidi.com), released under the MIT license
