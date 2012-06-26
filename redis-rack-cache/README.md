# Redis stores for Rack::Cache

__`redis-rack-cache`__ provides a Redis backed store for __Rack::Cache__. It natively supports object marshalling, timeouts, single or multiple nodes and namespaces.

## Redis Installation

### Option 1: Homebrew

MacOS X users should use [Homebrew](https://github.com/mxcl/homebrew) to install Redis:

    brew install redis

### Option 2: From Source

Download and install Redis from [http://redis.io](http://redis.io/)

	wget http://redis.googlecode.com/files/redis-2.4.15.tar.gz
    tar -zxf redis-2.4.15.tar.gz
    mv redis-2.4.15 redis
    cd redis
    make

## Usage

    # Gemfile
	gem 'redis-rack-cache'

### HTTP Cache Store:

    # config.ru
	require 'rack'
	require 'rack/cache'
	require 'redis-rack-cache'

	use Rack::Cache,
	  :metastore   => 'redis://localhost:6379/0/metastore',
	  :entitystore => 'redis://localhost:6380/0/entitystore'

#### Configuration

For advanced configuration options, please check the [Redis Store Wiki](https://github.com/jodosha/redis-store/wiki).

## Running tests

    git clone git://github.com/jodosha/redis-store.git
	cd redis-store/redis-rack-cache
	gem install bundler
	bundle exec rake

If you are on **Snow Leopard** you have to run `env ARCHFLAGS="-arch x86_64" bundle exec rake`

## Copyright

(c) 2009 - 2011 Luca Guidi - [http://lucaguidi.com](http://lucaguidi.com), released under the MIT license
