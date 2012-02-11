require 'test_helper'

class RedisStoreIntegrationTest < ActionController::IntegrationTest
  it "reads the data" do
    get '/set_session_value'
    response.must_be :success?
    cookies['_session_id'].wont_be_nil

    get '/get_session_value'
    response.must_be :success?
    response.body.must_equal 'foo: "bar"'
  end

  it "should get nil session value" do
    get '/get_session_value'
    response.must_be :success?
    response.body.must_equal 'foo: nil'
  end

  it "should delete the data after session reset" do
    get '/set_session_value'
    response.must_be :success?
    cookies['_session_id'].wont_be_nil
    session_cookie = cookies.send(:hash_for)['_session_id']

    get '/call_reset_session'
    response.must_be :success?
    headers['Set-Cookie'].wont_equal []

    cookies << session_cookie

    get '/get_session_value'
    response.must_be :success?
    response.body.must_equal 'foo: nil'
  end

  it "should not send cookies on write, not read" do
    get '/get_session_value'
    response.must_be :success?
    response.body.must_equal 'foo: nil'
    cookies['_session_id'].must_be_nil
  end

  it "should set session value after session reset" do
    get '/set_session_value'
    response.must_be :success?
    cookies['_session_id'].wont_be_nil
    session_id = cookies['_session_id']

    get '/call_reset_session'
    response.must_be :success?
    headers['Set-Cookie'].wont_equal []

    get '/get_session_value'
    response.must_be :success?
    response.body.must_equal 'foo: nil'

    get '/get_session_id'
    response.must_be :success?
    response.body.wont_equal session_id
  end

  it "should be able to read session id without accessing the session hash" do
    get '/set_session_value'
    response.must_be :success?
    cookies['_session_id'].wont_be_nil
    session_id = cookies['_session_id']

    get '/get_session_id'
    response.must_be :success?
    response.body.must_equal session_id
  end

  it "should auto-load unloaded class" do
    with_autoload_path "session_autoload_test" do
      get '/set_serialized_session_value'
      response.must_be :success?
      cookies['_session_id'].wont_be_nil
    end

    with_autoload_path "session_autoload_test" do
      get '/get_session_id'
      assert_response :success
    end

    with_autoload_path "session_autoload_test" do
      get '/get_session_value'
      response.must_be :success?
      response.body.must_equal 'foo: #<SessionAutoloadTest::Foo bar:"baz">'
    end
  end

  it "should not resend the cookie again if session_id cookie is already exists" do
    get '/set_session_value'
    response.must_be :success?
    cookies['_session_id'].wont_be_nil

    get '/get_session_value'
    response.must_be :success?
    headers['Set-Cookie'].must_be_nil
  end

  it "should prevent session fixation" do
    get '/get_session_value'
    response.must_be :success?
    response.body.must_equal 'foo: nil'
    session_id = cookies['_session_id']

    reset!

    get '/set_session_value', :_session_id => session_id
    response.must_be :success?
    cookies['_session_id'].wont_equal session_id
  end

  it "should write the data with expiration time" do
    get '/set_session_value_with_expiry'
    response.must_be :success?

    get '/get_session_value'
    response.must_be :success?
    response.body.must_equal 'foo: "bar"'

    sleep 1

    get '/get_session_value'
    response.must_be :success?
    response.body.must_equal 'foo: nil'
  end
end
