require 'test_helper'

class RedisStoreIntegrationTest < MiniTest::Rails::IntegrationTest
  it "reads the data" do
    get '/set_session_value'
    assert_response :success
    cookies['_session_id'].wont_be_nil

    get '/get_session_value'
    assert_response :success
    response.body.must_equal 'foo: "bar"'
  end

  it "should delete the data" do
    get '/set_session_value'
    assert_response :success
    cookies['_session_id'].wont_be_nil
    session_cookie = cookies.send(:hash_for)['_session_id']

    get '/call_reset_session'
    assert_response :success
    headers['Set-Cookie'].wont_equal []

    cookies << session_cookie

    get '/get_session_value'
    assert_response :success
    response.body.must_equal 'foo: nil'
  end

  #it "should write the data with expiration time" do
  #  with_store_management do |store|
  #    @env['rack.session.options'].merge!(:expires_in => 1.second)
  #    store.set_session(@env, @sid, @white_rabbit); sleep 2
  #    store.get_session(@env, @sid).must_equal([@sid, {}])
  #  end
  #end
end
