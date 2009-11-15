# steal the cool tasks from redis-rb
begin
  load File.join(File.dirname(__FILE__), "/../vendor/gems/gems/redis-rb-0.1/tasks/redis.tasks.rb")
rescue LoadError
end

class RedisRunner
  def self.port
    6379
  end

  def self.stop
    system %(echo "SHUTDOWN" | nc localhost #{port})
  end
end

class SingleRedisRunner < RedisRunner
  def self.redisconfdir
    File.expand_path(File.dirname(__FILE__) + "/../spec/config/single.conf")
  end
end

class MasterRedisRunner < RedisRunner
  def self.redisconfdir
    File.expand_path(File.dirname(__FILE__) + "/../spec/config/master.conf")
  end

  def self.dtach_socket
    "/tmp/redis_master.dtach"
  end

  def self.port
    6380
  end
end

class SlaveRedisRunner < RedisRunner
  def self.redisconfdir
    File.expand_path(File.dirname(__FILE__) + "/../spec/config/slave.conf")
  end

  def self.dtach_socket
    "/tmp/redis_slave.dtach"
  end

  def self.port 
    6381
  end
end

class RedisClusterRunner
  def self.runners
    [ SingleRedisRunner, MasterRedisRunner, SlaveRedisRunner ]
  end

  def self.start_detached
    runners.each do |runner|
      runner.start_detached
    end
  end

  def self.stop
    runners.each do |runner|
      runner.stop
    end
  end
end
