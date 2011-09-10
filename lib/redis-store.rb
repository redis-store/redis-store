require 'redis'
require 'redis/store'

class Redis
  autoload :Factory,          'redis/factory'
  autoload :DistributedStore, 'redis/distributed_store'

  class Store < self
    autoload :Namespace,   'redis/store/namespace'
    autoload :Marshalling, 'redis/store/marshalling'
    autoload :Version,     'redis/store/version'
  end
end

