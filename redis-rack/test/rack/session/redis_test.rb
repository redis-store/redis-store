require 'test_helper'
require 'rack/mock'
require 'thread'

describe Rack::Session::Redis do
  session_key = Rack::Session::Redis::DEFAULT_OPTIONS[:key]
  session_match = /#{session_key}=([0-9a-fA-F]+);/
  incrementor = lambda do |env|
    env["rack.session"]["counter"] ||= 0
    env["rack.session"]["counter"] += 1
    Rack::Response.new(env["rack.session"].inspect).to_a
  end
  drop_session = proc do |env|
    env['rack.session.options'][:drop] = true
    incrementor.call(env)
  end
  renew_session = proc do |env|
    env['rack.session.options'][:renew] = true
    incrementor.call(env)
  end
  defer_session = proc do |env|
    env['rack.session.options'][:defer] = true
    incrementor.call(env)
  end

  # # test Redis connection
  # Rack::Session::Redis.new(incrementor)
  #
  # it "faults on no connection" do
  #   lambda{
  #     Rack::Session::Redis.new(incrementor, :redis_server => 'nosuchserver')
  #   }.must_raise(Exception)
  # end

  it "uses the default Redis server and namespace when not provided" do
    pool = Rack::Session::Redis.new(incrementor)
    pool.pool.to_s.must_match(/127\.0\.0\.1:6379 against DB 0 with namespace rack:session$/)
  end

  it "uses the specified namespace when provided" do
    pool = Rack::Session::Redis.new(incrementor, :redis_server => {:namespace => 'test:rack:session'})
    pool.pool.to_s.must_match(/namespace test:rack:session$/)
  end

  it "uses the specified Redis server when provided" do
    pool = Rack::Session::Redis.new(incrementor, :redis_server => 'redis://127.0.0.1:6380/1')
    pool.pool.to_s.must_match(/127\.0\.0\.1:6380 against DB 1$/)
  end

  it "creates a new cookie" do
    pool = Rack::Session::Redis.new(incrementor)
    res = Rack::MockRequest.new(pool).get("/")
    res["Set-Cookie"].must_include("#{session_key}=")
    res.body.must_equal('{"counter"=>1}')
  end

  it "determines session from a cookie" do
    pool = Rack::Session::Redis.new(incrementor)
    req = Rack::MockRequest.new(pool)
    res = req.get("/")
    cookie = res["Set-Cookie"]
    req.get("/", "HTTP_COOKIE" => cookie).
      body.must_equal('{"counter"=>2}')
    req.get("/", "HTTP_COOKIE" => cookie).
      body.must_equal('{"counter"=>3}')
  end

  it "determines session only from a cookie by default" do
    pool = Rack::Session::Redis.new(incrementor)
    req = Rack::MockRequest.new(pool)
    res = req.get("/")
    sid = res["Set-Cookie"][session_match, 1]
    req.get("/?rack.session=#{sid}").
      body.must_equal('{"counter"=>1}')
    req.get("/?rack.session=#{sid}").
      body.must_equal('{"counter"=>1}')
  end

  it "determines session from params" do
    pool = Rack::Session::Redis.new(incrementor, :cookie_only => false)
    req = Rack::MockRequest.new(pool)
    res = req.get("/")
    sid = res["Set-Cookie"][session_match, 1]
    req.get("/?rack.session=#{sid}").
      body.must_equal('{"counter"=>2}')
    req.get("/?rack.session=#{sid}").
      body.must_equal('{"counter"=>3}')
  end

  it "survives nonexistant cookies" do
    bad_cookie = "rack.session=blarghfasel"
    pool = Rack::Session::Redis.new(incrementor)
    res = Rack::MockRequest.new(pool).
      get("/", "HTTP_COOKIE" => bad_cookie)
    res.body.must_equal('{"counter"=>1}')
    cookie = res["Set-Cookie"][session_match]
    cookie.wont_match(/#{bad_cookie}/)
  end

  it "maintains freshness" do
    pool = Rack::Session::Redis.new(incrementor, :expire_after => 3)
    res = Rack::MockRequest.new(pool).get('/')
    res.body.must_include('"counter"=>1')
    cookie = res["Set-Cookie"]
    sid = cookie[session_match, 1]
    res = Rack::MockRequest.new(pool).get('/', "HTTP_COOKIE" => cookie)
    res["Set-Cookie"][session_match, 1].must_equal(sid)
    res.body.must_include('"counter"=>2')
    puts 'Sleeping to expire session' if $DEBUG
    sleep 4
    res = Rack::MockRequest.new(pool).get('/', "HTTP_COOKIE" => cookie)
    res["Set-Cookie"][session_match, 1].wont_equal(sid)
    res.body.must_include('"counter"=>1')
  end

  it "does not send the same session id if it did not change" do
    pool = Rack::Session::Redis.new(incrementor)
    req = Rack::MockRequest.new(pool)

    res0 = req.get("/")
    cookie = res0["Set-Cookie"]
    res0.body.must_equal('{"counter"=>1}')

    res1 = req.get("/", "HTTP_COOKIE" => cookie)
    res1["Set-Cookie"].must_be_nil
    res1.body.must_equal('{"counter"=>2}')

    res2 = req.get("/", "HTTP_COOKIE" => cookie)
    res2["Set-Cookie"].must_be_nil
    res2.body.must_equal('{"counter"=>3}')
  end

  it "deletes cookies with :drop option" do
    pool = Rack::Session::Redis.new(incrementor)
    req = Rack::MockRequest.new(pool)
    drop = Rack::Utils::Context.new(pool, drop_session)
    dreq = Rack::MockRequest.new(drop)

    res1 = req.get("/")
    session = (cookie = res1["Set-Cookie"])[session_match]
    res1.body.must_equal('{"counter"=>1}')

    res2 = dreq.get("/", "HTTP_COOKIE" => cookie)
    res2["Set-Cookie"].must_be_nil
    res2.body.must_equal('{"counter"=>2}')

    res3 = req.get("/", "HTTP_COOKIE" => cookie)
    res3["Set-Cookie"][session_match].wont_equal(session)
    res3.body.must_equal('{"counter"=>1}')
  end

  it "provides new session id with :renew option" do
    pool = Rack::Session::Redis.new(incrementor)
    req = Rack::MockRequest.new(pool)
    renew = Rack::Utils::Context.new(pool, renew_session)
    rreq = Rack::MockRequest.new(renew)

    res1 = req.get("/")
    session = (cookie = res1["Set-Cookie"])[session_match]
    res1.body.must_equal('{"counter"=>1}')

    res2 = rreq.get("/", "HTTP_COOKIE" => cookie)
    new_cookie = res2["Set-Cookie"]
    new_session = new_cookie[session_match]
    new_session.wont_equal(session)
    res2.body.must_equal('{"counter"=>2}')

    res3 = req.get("/", "HTTP_COOKIE" => new_cookie)
    res3.body.must_equal('{"counter"=>3}')

    # Old cookie was deleted
    res4 = req.get("/", "HTTP_COOKIE" => cookie)
    res4.body.must_equal('{"counter"=>1}')
  end

  it "omits cookie with :defer option" do
    pool = Rack::Session::Redis.new(incrementor)
    defer = Rack::Utils::Context.new(pool, defer_session)
    dreq = Rack::MockRequest.new(defer)

    res0 = dreq.get("/")
    res0["Set-Cookie"].must_be_nil
    res0.body.must_equal('{"counter"=>1}')
  end

  it "updates deep hashes correctly" do
    hash_check = proc do |env|
      session = env['rack.session']
      unless session.include? 'test'
        session.update :a => :b, :c => { :d => :e },
          :f => { :g => { :h => :i} }, 'test' => true
      else
        session[:f][:g][:h] = :j
      end
      [200, {}, [session.inspect]]
    end
    pool = Rack::Session::Redis.new(hash_check)
    req = Rack::MockRequest.new(pool)

    res0 = req.get("/")
    session_id = (cookie = res0["Set-Cookie"])[session_match, 1]
    ses0 = pool.pool.get(session_id)

    req.get("/", "HTTP_COOKIE" => cookie)
    ses1 = pool.pool.get(session_id)

    ses1.wont_equal(ses0)
  end

  # anyone know how to do this better?
  it "cleanly merges sessions when multithreaded" do
    unless $DEBUG
      1.must_equal(1) # fake assertion to appease the mighty bacon
      next
    end
    warn 'Running multithread test for Session::Redis'
    pool = Rack::Session::Redis.new(incrementor)
    req = Rack::MockRequest.new(pool)

    res = req.get('/')
    res.body.must_equal('{"counter"=>1}')
    cookie = res["Set-Cookie"]
    session_id = cookie[session_match, 1]

    delta_incrementor = lambda do |env|
      # emulate disconjoinment of threading
      env['rack.session'] = env['rack.session'].dup
      Thread.stop
      env['rack.session'][(Time.now.usec*rand).to_i] = true
      incrementor.call(env)
    end
    tses = Rack::Utils::Context.new pool, delta_incrementor
    treq = Rack::MockRequest.new(tses)
    tnum = rand(7).to_i+5
    r = Array.new(tnum) do
      Thread.new(treq) do |run|
        run.get('/', "HTTP_COOKIE" => cookie, 'rack.multithread' => true)
      end
    end.reverse.map{|t| t.run.join.value }
    r.each do |request|
      request['Set-Cookie'].must_equal(cookie)
      request.body.must_include('"counter"=>2')
    end

    session = pool.pool.get(session_id)
    session.size.must_equal(tnum+1) # counter
    session['counter'].must_equal(2) # meeeh

    tnum = rand(7).to_i+5
    r = Array.new(tnum) do |i|
      app = Rack::Utils::Context.new pool, time_delta
      req = Rack::MockRequest.new app
      Thread.new(req) do |run|
        run.get('/', "HTTP_COOKIE" => cookie, 'rack.multithread' => true)
      end
    end.reverse.map{|t| t.run.join.value }
    r.each do |request|
      request['Set-Cookie'].must_equal(cookie)
      request.body.must_include('"counter"=>3')
    end

    session = pool.pool.get(session_id)
    session.size.must_equal(tnum+1)
    session['counter'].must_equal(3)

    drop_counter = proc do |env|
      env['rack.session'].delete 'counter'
      env['rack.session']['foo'] = 'bar'
      [200, {'Content-Type'=>'text/plain'}, env['rack.session'].inspect]
    end
    tses = Rack::Utils::Context.new pool, drop_counter
    treq = Rack::MockRequest.new(tses)
    tnum = rand(7).to_i+5
    r = Array.new(tnum) do
      Thread.new(treq) do |run|
        run.get('/', "HTTP_COOKIE" => cookie, 'rack.multithread' => true)
      end
    end.reverse.map{|t| t.run.join.value }
    r.each do |request|
      request['Set-Cookie'].must_equal(cookie)
      request.body.must_include('"foo"=>"bar"')
    end

    session = pool.pool.get(session_id)
    session.size.must_equal(r.size+1)
    session['counter'].must_be_nil
    session['foo'].must_equal('bar')
  end
end
