# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rapidftr_session',
  :secret      => 'be44cca0615da68cfcbd7ecbe1617961961fd54c26f3606ac00adcf0318e47ff953592c8a6e2788fb45fac85b7710a7c2742959f1dbd9d66cd87d5c3866b55a1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
