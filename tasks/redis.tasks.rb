# steal the cool tasks from redis-rb
begin
  load File.join(File.dirname(__FILE__), "/../vendor/gems/gems/redis-rb-0.1/tasks/redis.tasks.rb")
rescue LoadError
end
