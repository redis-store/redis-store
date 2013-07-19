# Redis stores for ActiveSupport

__`redis-activesupport`__ provides a cache for __ActiveSupport__. See the main [redis-store readme](https://github.com/jodosha/redis-store) for general guidelines.

## Installation

    # Gemfile
    gem 'redis-activesupport'

### Usage

If you are using redis-store with Rails, consider using the [redis-rails gem](https://github.com/jodosha/redis-store/tree/master/redis-rails) instead. For standalone usage:

    ActiveSupport::Cache.lookup_store :redis_store # { ... optional configuration ... }

### Note on Cache Expiring & ActiveSupport::Notifications Subscription

Because you can only delete keys in Redis by referencing to the keys in an explicit manner, It is not possible to use Regex options for your expire_fragment calls ( in ActionController::Caching ) such as:

  `expire_fragment %r{regex-pattern}` 

However, wildcard Redis key matches are supported to expire cache, such as:

  `expire_fragment "rabb*"`

Because of the above, `redis-store` will not fanout any notifications for `cache_delete.active_support` event (as of this writing). All notifications for expiring cache are triggered as `cache_delete_matched.active_support` instrument. And you should be subscribing to this event rather than `cache_delete.active_support` in case you are subscribing to these events in your code at all.

## Running tests

    gem install bundler
    git clone git://github.com/jodosha/redis-store.git
    cd redis-store/redis-activesupport
    bundle install
    bundle exec rake

If you are on **Snow Leopard** you have to run `env ARCHFLAGS="-arch x86_64" bundle exec rake`

## Copyright

(c) 2009 - 2011 Luca Guidi - [http://lucaguidi.com](http://lucaguidi.com), released under the MIT license
