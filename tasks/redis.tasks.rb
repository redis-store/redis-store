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
    system %(redis-cli -p #{port} SHUTDOWN)
  end
end

class MainRedisRunner < RedisRunner
  def self.redisconfdir
    File.expand_path(File.dirname(__FILE__) + "/../spec/config/redis.conf")
  end
end

class NodeOneRedisRunner < RedisRunner
  def self.redisconfdir
    File.expand_path(File.dirname(__FILE__) + "/../spec/config/node-one.conf")
  end

  def self.dtach_socket
    "/tmp/redis-node-one.dtach"
  end

  def self.port
    6380
  end
end

class NodeTwoRedisRunner < RedisRunner
  def self.redisconfdir
    File.expand_path(File.dirname(__FILE__) + "/../spec/config/node-two.conf")
  end

  def self.dtach_socket
    "/tmp/redis-node-two.dtach"
  end

  def self.port
    6381
  end
end

class RedisReplicationRunner
  def self.runners
    [ MainRedisRunner, NodeOneRedisRunner, NodeTwoRedisRunner ]
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
  task :start => 'dtach:check' do
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
      when "1.3.12" then "26ef09a83526e5099bce"
      when "2.2.8"  then "ec279203df0bc6ddc981"
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

  namespace :replication do
    desc "Starts redis replication servers"
    task :start => 'dtach:check' do
      result = RedisReplicationRunner.start_detached
      raise("Could not start redis-server, aborting.") unless result
    end

    desc "Stops redis replication servers"
    task :stop do
      RedisReplicationRunner.stop
    end

    desc "Open an IRb session with the master/slave replication"
    task :console do
      RedisReplicationRunner.start_detached
      system "bundle exec irb -I lib -I extra -r redis-store.rb"
      RedisReplicationRunner.stop
    end
  end
end

namespace :dtach do
  desc 'About dtach'
  task :about do
    puts "\nSee http://dtach.sourceforge.net/ for information about dtach.\n\n"
  end

  desc 'Check that dtach is available'
  task :check do
    if !ENV['TRAVIS'] && !system('which dtach')
      raise "dtach is not installed. Install it manually or run 'rake dtach:install'"
    end
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

def invoke_with_redis_replication(task_name)
  begin
    Rake::Task["redis:replication:start"].invoke
    Rake::Task[task_name].invoke
  ensure
    Rake::Task["redis:replication:stop"].invoke
  end
end
