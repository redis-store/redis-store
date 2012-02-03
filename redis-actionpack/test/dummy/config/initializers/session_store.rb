# Be sure to restart your server when you modify this file.

Dummy::Application.config.session_store :redis_store,
  :key => '_session_id',
  :servers => ["redis://127.0.0.1:6380/1/theplaylist",
    "redis://127.0.0.1:6381/1/theplaylist"]

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Dummy::Application.config.session_store :active_record_store
