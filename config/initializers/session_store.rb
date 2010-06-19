# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_cp_session',
  :secret      => '47366c94d1ef34266479eb28ed48bf88b702c36ef9579468ddc3326dc77a3f9db4dd8df0fb163cbaab773e5b16b42cfa539493acb187e358cbf4d8ef4cde72a0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
