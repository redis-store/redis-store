# Be sure to restart your server when you modify this file.

Dummy::Application.config.session_store :redis_session_store,
  :key => '_session_id'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Dummy::Application.config.session_store :active_record_store
