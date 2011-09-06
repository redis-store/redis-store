# Namespaced Rack::Session, Rack::Cache, I18n and cache Redis stores for Ruby web frameworks

## Installation

### Redis, Option 1: Homebrew

MacOS X users should use [Homebrew](https://github.com/mxcl/homebrew) to install Redis:

    brew install redis

### Redis, Option 2: From Source

Download and install Redis from [http://code.google.com/p/redis/](http://code.google.com/p/redis/)

    wget http://redis.googlecode.com/files/redis-2.0.0.tar.gz
    tar -zxf redis-2.0.0.tar.gz
    mv redis-2.0.0 redis
    cd redis
    make

### Install the Gem

Assuming you're using RVM or on Windows, install the gem with:

    gem install redis-store

## Options
You can specify the Redis configuration details using a URI or a hash.  By default the gem will attempt to connect to `localhost` port `6379` and the db `0`.

### Set by URI

For example

    "redis://:secret@192.168.1.100:23682/13/theplaylist"

Made up of the following:

    host: 192.168.1.100
    port: 23682
    db: 13
    namespace: theplaylist
    password: secret

If you want to specify the `namespace` option, you have to pass the `db` param too.
#### __Important__: `namespace` is only supported for single, non-distributed stores.

### Set by Hash

    { :host => 192.168.1.100, :port => 23682, :db => 13, :namespace => "theplaylist", :password => "secret" }

#### __Important__: `namespace` is only supported for single, non-distributed stores.

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
    gem 'redis'
    gem 'redis-store', '1.0.0.1'

    # config/environments/production.rb
    config.cache_store = :redis_store, { ... optional configuration ... }

For advanced configurations scenarios please visit [the wiki](https://github.com/jodosha/redis-store/wiki/Frameworks-Configuration).

### Merb

    dependency "redis-store", "1.0.0.1"
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
        settings.cache.fetch("greet") { "Hello, World!" }
      end
    end

Keep in mind that the above fetch will return "OK" on success, not the return of the block.

For advanced configurations scenarios please visit [the wiki](https://github.com/jodosha/redis-store/wiki/Frameworks-Configuration).

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
    gem 'redis-store', '1.0.0.1'

    # config/initializers/session_store.rb
    MyApp::Application.config.session_store :redis_session_store

For advanced configurations scenarios please visit [the wiki](https://github.com/jodosha/redis-store/wiki/Frameworks-Configuration).

### Merb

    dependency "redis-store", "1.0.0.1"
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
      use Rack::Session::Redis, :redis_server => 'redis://127.0.0.1:6379/0' # Redis server on localhost port 6379, database 0

      get "/" do
        session[:visited_at] = DateTime.now.to_s # This is stored in Redis
        "Hello, visitor."
      end
    end

For advanced configurations scenarios please visit [the wiki](https://github.com/jodosha/redis-store/wiki/Frameworks-Configuration).

## Rack::Cache

Provides a Redis store for HTTP caching. See [http://github.com/rtomayko/rack-cache](http://github.com/rtomayko/rack-cache)

    require "rack"
    require "rack/cache"
    require "redis-store"
    require "application"
    use Rack::Cache,
      :metastore   => 'redis://localhost:6379/0/metastore',
      :entitystore => 'redis://localhost:6380/0/entitystore'
    run Application.new

## I18n

    require "i18n"
    require "redis-store"
    I18n.backend = I18n::Backend::Redis.new

The backend accepts the uri string and hash options.

## Unicorn

Use `Rails.cache.reconnect` in your Unicorn hooks, in order to force the client reconnection.

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

(c) 2009 - 2011 Luca Guidi - [http://lucaguidi.com](http://lucaguidi.com), released under the MIT license
