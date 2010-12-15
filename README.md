# Namespaced Rack::Session, Rack::Cache, I18n and cache Redis stores for Ruby web frameworks

## Installation

Download and install Redis from [http://code.google.com/p/redis/](http://code.google.com/p/redis/)

    wget http://redis.googlecode.com/files/redis-2.0.0.tar.gz
    tar -zxf redis-2.0.0.tar.gz
    mv redis-2.0.0 redis
    cd redis
    make

Install the gem

    sudo gem install redis-store

## Options
There are two ways to configure the Redis server options: by an URI string and by an hash.
By default each store try to connect on `localhost` with the port `6379` and the db `0`.

### String

    "redis://:secret@192.168.1.100:23682/13/theplaylist"

    host: 192.168.1.100
    port: 23682
    db: 13
    namespace: theplaylist
    password: secret

If you want to specify the `namespace` optional, you have to pass the `db` param too.
#### __Important__: for now (beta4) `namespace` is only supported for single, non-distributed stores.

### Hash

    { :host => 192.168.1.100, :port => 23682, :db => 13, :namespace => "theplaylist", :password => "secret" }

#### __Important__: for now (beta4) `namespace` is only supported for single, non-distributed stores.

## Cache store

Provides a cache store for your Ruby web framework of choice.

### Rails 2.x

    config.gem "redis-store"
    config.cache_store = :redis_store

### Rails 2.x (with Bundler)

    # Gemfile
    gem "redis-store"

    # in your configuration
    config.gem "redis-store"
    config.cache_store = :redis_store, { ... optional configuration ... }

### Rails 3.x

    # Gemfile
    gem 'rails', '3.0.3'
    gem 'redis'
    gem 'redis-store', '1.0.0.beta4'

    # config/environments/production.rb
    config.cache_store = :redis_store, { ... optional configuration ... }

For advanced configurations scenarios please visit [the wiki](http://wiki.github.com/jodosha/redis-store/rails).

### Merb

    dependency "redis-store", "1.0.0.beta4"
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

### Rails 2.x

    # config/environment.rb
    config.gem "redis-store"

    # then configure as following:

    # config/environments/*.rb
    config.cache_store = :redis_store

    # or

    # config/initializers/session_store.rb
    ActionController::Base.session = {
      :key         => APPLICATION['session_key'],
      :secret      => APPLICATION['session_secret'],
      :key_prefix  => Rails.env
    }

    ActionController::Base.session_store = :redis_session_store

### Rails 2.x (with Bundler)

    # Gemfile
    gem "redis-store"

    # then configure as following:

    # config/environments/*.rb
    config.cache_store = :redis_store

    # or

    # config/initializers/session_store.rb
    ActionController::Base.session = {
      :key         => APPLICATION['session_key'],
      :secret      => APPLICATION['session_secret'],
      :key_prefix  => Rails.env
    }

    ActionController::Base.session_store = :redis_session_store

### Rails 3.x

    # Gemfile
    gem 'rails', '3.0.3'
    gem 'redis'
    gem 'redis-store', '1.0.0.beta4'

    # config/initializers/session_store.rb
    MyApp::Application.config.session_store :redis_session_store

For advanced configurations scenarios please visit [the wiki](http://wiki.github.com/jodosha/redis-store/rails).

### Merb

    dependency "redis-store", "1.0.0.beta4"
    Merb::Config.use do |c|
      c[:session_store] = "redis"
    end
    Merb::BootLoader.before_app_loads do
      Merb::SessionContainer.subclasses << "Merb::RedisSession"
    end

### Sinatra

    require "sinatra"
    require "redis-store"

    class MyApp < Sinatra::Base
      use Rack::Session::Redis

      get "/" do
        session[:visited_at] = DateTime.now.to_s # This is stored in Redis
        "Hello, visitor."
      end
    end

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

## I18n

    require "i18n"
    require "redis-store"
    I18n.backend = I18n::Backend::Redis.new

The backend accepts the uri string and hash options.

## Running specs

    gem install jeweler bundler
    git clone git://github.com/jodosha/redis-store.git
    cd redis-store
    bundle install
    REDIS_STORE_ENV=rails3 bundle install # to install Rails 3 gems
    rake dtach:install
    rake redis:install
    rake
    REDIS_STORE_ENV=rails3 rake # to test against Rails 3

If you are on **Snow Leopard** you have to run `env ARCHFLAGS="-arch x86_64" bundle install`

## Copyright

(c) 2009 - 2010 Luca Guidi - [http://lucaguidi.com](http://lucaguidi.com), released under the MIT license
