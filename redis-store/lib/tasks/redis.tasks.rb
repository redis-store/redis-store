require 'rake'
require 'rake/testtask'
require 'fileutils'
require 'open-uri'

class RedisRunner
  def self.redisdir
    File.expand_path("../../../vendor/redis", __FILE__)
  end

  def self.configuration
    File.expand_path("../../../test/config/redis.conf", __FILE__)
  end

  def self.pid_file
    File.expand_path(Dir.pwd + "/tmp/pids/redis.pid")
  end

  def self.pid
    File.open(pid_file).read.to_i
  end

  def self.start
    system %(redis-server #{configuration})
  end

  def self.stop
    begin
      Process.kill('SIGTERM', pid)
    rescue
      # Suppress exceptions for Travis CI
    end
  end
end

class NodeOneRedisRunner < RedisRunner
  def self.configuration
    File.expand_path("../../../test/config/node-one.conf", __FILE__)
  end

  def self.pid_file
    File.expand_path(Dir.pwd + "/tmp/pids/node-one.pid")
  end
end

class NodeTwoRedisRunner < RedisRunner
  def self.configuration
    File.expand_path("../../../test/config/node-two.conf", __FILE__)
  end

  def self.pid_file
    File.expand_path(Dir.pwd + "/tmp/pids/node-two.pid")
  end
end

class RedisReplicationRunner
  def self.runners
    [ RedisRunner, NodeOneRedisRunner, NodeTwoRedisRunner ]
  end

  def self.start
    runners.each do |runner|
      runner.start
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
      when "1.3.12"  then "26ef09a83526e5099bce"
      when "2.2.12"  then "5960ac9dec5184bf4184"
      when "2.2.4"   then "2b886275e9756bb8619a"
      when "2.0.5"   then "9b695bb0a00c01ad4d55"
    end

    arguments = commit.nil? ? "pull origin master" : "reset --hard #{commit}"
    sh "cd #{RedisRunner.redisdir} && git #{arguments}"
  end

  namespace :test do
    desc "Run all the examples by starting a background Redis instance"
    task :suite => 'redis:test:prepare' do
      invoke_with_redis_replication 'redis:test:run'
    end

    Rake::TestTask.new(:run) do |t|
      t.libs.push 'lib'
      t.test_files = FileList['test/**/*_test.rb']
      t.ruby_opts  = ["-I test"]
      t.verbose    = true
    end

    task :prepare do
      FileUtils.mkdir_p 'tmp/pids'
      FileUtils.rm Dir.glob('tmp/*.rdb')
    end
  end

  namespace :replication do
    desc "Starts redis replication servers"
    task :start do
      RedisReplicationRunner.start
    end

    desc "Stops redis replication servers"
    task :stop do
      RedisReplicationRunner.stop
    end

    desc "Open an IRb session with the master/slave replication"
    task :console do
      RedisReplicationRunner.start
      system "bundle exec irb -I lib -I extra -r redis-store.rb"
      RedisReplicationRunner.stop
    end
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

