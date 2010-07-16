# inspired by old Rake tasks from redis-rb
require 'rake'
require 'fileutils'
require 'open-uri'

class RedisRunner
  def self.port
    6379
  end

  def self.redisdir
    @@redisdir ||= File.expand_path File.join(File.dirname(__FILE__), '..', 'vendor', 'redis')
  end

  def self.redisconfdir
    '/etc/redis.conf'
  end

  def self.dtach_socket
    '/tmp/redis.dtach'
  end

  # Just check for existance of dtach socket
  def self.running?
    File.exists? dtach_socket
  end

  def self.start
    puts 'Detach with Ctrl+\  Re-attach with rake redis:attach'
    sleep 3
    exec "dtach -A #{dtach_socket} redis-server #{redisconfdir}"
  end

  def self.start_detached
    system "dtach -n #{dtach_socket} redis-server #{redisconfdir}"
  end

  def self.attach
    exec "dtach -a #{dtach_socket}"
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

namespace :redis do
  desc 'About redis'
  task :about do
    puts "\nSee http://code.google.com/p/redis/ for information about redis.\n\n"
  end

  desc 'Start redis'
  task :start do
    RedisRunner.start
  end

  desc 'Stop redis'
  task :stop do
    RedisRunner.stop
  end

  desc 'Restart redis'
  task :restart do
    RedisRunner.stop
    RedisRunner.start
  end

  desc 'Attach to redis dtach socket'
  task :attach do
    RedisRunner.attach
  end

  desc 'Install the lastest verison of Redis from Github (requires git, duh)'
  task :install => [ :about, :download, :make ] do
    %w(redis-benchmark redis-cli redis-server).each do |bin|
      if File.exist?(path = "#{RedisRunner.redisdir}/src/#{bin}")
        sh "sudo cp #{path} /usr/bin/"
      else
        sh "sudo cp #{RedisRunner.redisdir}/#{bin} /usr/bin/"
      end
    end

    puts "Installed redis-benchmark, redis-cli and redis-server to /usr/bin/"

    sh "sudo cp #{RedisRunner.redisdir}/redis.conf /etc/"
    puts "Installed redis.conf to /etc/ \n You should look at this file!"
  end

  task :make do
    sh "cd #{RedisRunner.redisdir} && make clean"
    sh "cd #{RedisRunner.redisdir} && make"
  end

  desc "Download package"
  task :download do
    require 'git'

    sh "rm -rf #{RedisRunner.redisdir} && mkdir -p vendor && rm -rf redis"
    Git.clone("git://github.com/antirez/redis.git", "redis")
    sh "mv redis vendor"

    commit = case ENV['VERSION']
      when "1.2.6" then "570e43c8285a4e5e3f31"
    end

    arguments = commit.nil? ? "pull origin master" : "reset --hard #{commit}"
    sh "cd #{RedisRunner.redisdir} && git #{arguments}"
  end

  desc "Open an IRb session"
  task :console do
    RedisRunner.start_detached
    system "bundle exec irb -I lib -I extra -r redis-store.rb"
    RedisRunner.stop
  end

  namespace :cluster do
    desc "Starts the redis_cluster"
    task :start do
      result = RedisClusterRunner.start_detached
      raise("Could not start redis-server, aborting.") unless result
    end

    desc "Stops the redis_cluster"
    task :stop do
      RedisClusterRunner.stop
    end
  end  
end

namespace :dtach do
  desc 'About dtach'
  task :about do
    puts "\nSee http://dtach.sourceforge.net/ for information about dtach.\n\n"
  end

  desc 'Install dtach 0.8 from source'
  task :install => [:about] do

    Dir.chdir('/tmp/')
    unless File.exists?('/tmp/dtach-0.8.tar.gz')
      require 'net/http'

      url = 'http://downloads.sourceforge.net/project/dtach/dtach/0.8/dtach-0.8.tar.gz'
      open('/tmp/dtach-0.8.tar.gz', 'wb') do |file| file.write(open(url).read) end
    end

    unless File.directory?('/tmp/dtach-0.8')
      system('tar xzf dtach-0.8.tar.gz')
    end

    Dir.chdir('/tmp/dtach-0.8/')
    sh 'cd /tmp/dtach-0.8/ && ./configure && make'
    sh 'sudo cp /tmp/dtach-0.8/dtach /usr/bin/'

    puts 'Dtach successfully installed to /usr/bin.'
  end
end

def invoke_with_redis_cluster(task_name)
  begin
    Rake::Task["redis:cluster:start"].invoke
    Rake::Task[task_name].invoke
  ensure
    Rake::Task["redis:cluster:stop"].invoke
  end
end
