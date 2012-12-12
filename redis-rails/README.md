# Redis stores for Ruby on Rails

__`redis-rails`__ provides a full set of stores (*Cache*, *Session*, *HTTP Cache*) for __Ruby on Rails__. See the main [redis-store readme](https://github.com/jodosha/redis-store) for general guidelines.

## Installation

    # Gemfile
    gem 'redis-rails' # Will install several other redis- gems

### Usage

For Rails 3.2:

    # config/application.rb
    config.cache_store = :redis_store, "redis://localhost:6379/0/cache", { expires_in: 90.minutes }

Configuration values at the end are optional. If you want to use Redis as a backend for sessions, you will also need to set:

    # config/initializers/session_store.rb
    MyApplication::Application.config.session_store :redis_store

And if you would like to use Redis as a rack-cache backend for HTTP caching:

    # config/environments/production.rb
    config.action_dispatch.rack_cache = {
      metastore:   "redis://localhost:6379/1/metastore",
      entitystore: "redis://localhost:6379/1/entitystore"
    }

## Running tests

    gem install bundler
    git clone git://github.com/jodosha/redis-store.git
    cd redis-store/redis-rails
    bundle install
    bundle exec rake

If you are on **Snow Leopard** you have to run `env ARCHFLAGS="-arch x86_64" bundle exec rake`

## Copyright

(c) 2009 - 2011 Luca Guidi - [http://lucaguidi.com](http://lucaguidi.com), released under the MIT license
