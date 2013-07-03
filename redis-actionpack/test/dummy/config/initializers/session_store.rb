# Be sure to restart your server when you modify this file.

Dummy::Application.config.session_store :redis_store,
  :key => '_session_id',
  :servers => {
    :host =>  "127.0.0.1",
    :port =>  6380,
    :db =>  1,
    :namespace =>  'theplaylist',
    :expire_after => 1
  }

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Dummy::Application.config.session_store :active_record_store
