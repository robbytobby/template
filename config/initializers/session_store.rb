# Be sure to restart your server when you modify this file.

Yacht::Application.config.session_store :cookie_store, key: '_yacht_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Yacht::Application.config.session_store :active_record_store
