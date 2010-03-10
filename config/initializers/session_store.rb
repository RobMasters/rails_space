# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_rails_space_session',
  :secret => '7ff3a1472b3b5e62c1f58faaf4b1fac6cb1c107a88bbb4d671176a7fce12797af0f0ac45af23badd14d58230c6f37a84123c4388b7ab860696e3f6d242c8fbd4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
