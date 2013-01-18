# Redis stores for I18n

__`redis-i18n`__ provides a Redis backend for __I18n__. See the main [redis-store readme](https://github.com/jodosha/redis-store) for general guidelines.

## Installation

    # Gemfile
    gem 'redis-i18n'

### Usage

If you are using redis-store with Rails, consider using the [redis-rails gem](https://github.com/jodosha/redis-store/tree/master/redis-rails) instead. For standalone usage:

    I18n.backend = I18n::Backend::Redis.new

## Running tests

    gem install bundler
    git clone git://github.com/jodosha/redis-store.git
    cd redis-store/redis-i18n
    bundle install
    bundle exec rake

If you are on **Snow Leopard** you have to run `env ARCHFLAGS="-arch x86_64" bundle exec rake`

## Copyright

(c) 2009 - 2011 Luca Guidi - [http://lucaguidi.com](http://lucaguidi.com), released under the MIT license
