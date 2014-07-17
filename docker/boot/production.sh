#!/usr/bin/env bash

cd /rapidftr

if [ ! -f config/couchdb.yml ]; then
  #Generate random username/password for CouchDB
  password=$(uuidgen | tr -d '-')
  username=$(uuidgen | tr -d '-')
  echo -e "[admins]\n$username = $password" > /etc/couchdb/local.d/rapidftr-security.ini
  bundle exec rake db:create_couchdb_yml[$username,$password]
fi

# Precompile assets
bundle exec rake assets:clobber assets:precompile

# Seed database
# (this will be obsolete after "first run wizard" deployment stories are played)
runsv /etc/service/couchdb &
sleep 2
bundle exec rake db:seed db:migrate
sv shutdown couchdb
sleep 2

# Make sure permissions are unchanged
chown -R www-data:www-data .
