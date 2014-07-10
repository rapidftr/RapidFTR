#!/usr/bin/env bash

# Generate random username/password for CouchDB
password=$(uuidgen | tr -d '-')
username=$(uuidgen | tr -d '-')
echo -e "[admins]\n$username = $password" > /etc/couchdb/local.d/security.ini

# Start CouchDB in order to do the seeding
runsv /etc/service/couchdb &
sleep 2

# First-time configuration (DB, Assets, Seeds)
cd /rapidftr
bundle exec rake db:create_couchdb_yml[$username,$password]
bundle exec rake assets:clean assets:precompile
bundle exec rake db:seed db:migrate
chown -R www-data:www-data /rapidftr

# Shutdown CouchDB, it will be started again later
sv shutdown couchdb
sleep 2

# Remove this file once it is run
rm /etc/my_init.d/000_setup_rapidftr.sh
