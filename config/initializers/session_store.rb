# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_sample_session',
  :secret      => 'de1babee02963d55941f8dbf5d9d26657aad4b789014c942285eded9ec10b71dbc6e52870eddf9dd9f9c0c8457b63c53822096721296210e886088a2bb46aba7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
