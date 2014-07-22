#!/usr/bin/env bash
# Run upon first boot of RapidFTR container
# This service is complicated, because of many circular dependencies, need to refactor

mkdir -p /data/couchdb
chown -R couchdb:couchdb /data/couchdb

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
chown -R www-data:www-data .
runsv /etc/service/couchdb &
runsv /etc/service/solr &
sleep 5

bundle exec rake db:seed db:migrate
bundle exec rake sunspot:reindex

sv shutdown couchdb
sv shutdown solr
killall java
sleep 5

# Generate a self-signed SSL certificate if none found
mkdir -p /data/ssl
if [ ! -f /data/ssl/certificate.crt ]; then
  echo "********************************************"
  echo "********************************************"
  echo "***  WARNING:  No SSL certificate found  ***"
  echo "*** Generating a self-signed certificate ***"
  echo "***    Please use a proper certificate   ***"
  echo "********************************************"
  echo "********************************************"
  openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=UG/ST=Kampala/L=Kampala/O=RapidFTRDemo/CN=localhost" -keyout /data/ssl/certificate.key -out /data/ssl/certificate.crt
fi
chown -R root:root /data/ssl
chmod 0600 /data/ssl

# Make sure permissions are unchanged
chown -R www-data:www-data .
