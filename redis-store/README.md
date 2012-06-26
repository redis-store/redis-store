# Redis stores for Ruby frameworks

__Redis Store__ provides a full set of stores (*Cache*, *I18n*, *Session*, *HTTP Cache*) for all the modern Ruby frameworks like: __Ruby on Rails__, __Sinatra__, __Rack__, __Rack::Cache__ and __I18n__. It natively supports object marshalling, timeouts, single or multiple nodes and namespaces.

This is the core for all the other gems, please check the *READMEs* to be informed about the usage.

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

## Running tests

    git clone git://github.com/jodosha/redis-store.git
	cd redis-store/redis-store
	gem install bundler
	ruby ci/run.rb

If you are on **Snow Leopard** you have to run `env ARCHFLAGS="-arch x86_64" ruby ci/run.rb`

## Copyright

(c) 2009 - 2011 Luca Guidi - [http://lucaguidi.com](http://lucaguidi.com), released under the MIT license
