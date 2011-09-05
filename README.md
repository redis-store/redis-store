# Namespaced Redis stores for Ruby web frameworks

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
