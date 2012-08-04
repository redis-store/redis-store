require 'redis'
require 'redis/store'
require 'redis/factory'
require 'redis/distributed_store'
require 'redis/store/namespace'
require 'redis/store/marshalling'
require 'redis/store/version'
require 'redis/store/adapters/json'
require 'redis/store/adapters/marshal'

class Redis
  class Store < self
  end
end