#!/usr/bin/env bash
# Run upon first boot of RapidFTR container
# This service is complicated because of many circular dependencies with runit

# Generate a self-signed SSL certificate if none found
mkdir -p /data/ssl
if [ ! -f /data/ssl/certificate.crt ]; then
  echo "********************************************"
  echo "********************************************"
  echo "***  WARNING:  NO SSL CERTIFICATE FOUND  ***"
  echo "*** GENERATING A SELF-SIGNED CERTIFICATE ***"
  echo "***    PLEASE USE A PROPER CERTIFICATE   ***"
  echo "********************************************"
  echo "********************************************"
  openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=XX/ST=FIXME/L=FIXME/O=FIXME/CN=FIXME" -keyout /data/ssl/certificate.key -out /data/ssl/certificate.crt
fi
chown -R root:root /data/ssl
chmod 0700 /data/ssl
chmod 0600 /data/ssl/*

# Generate random username/password for CouchDB
cd /rapidftr
if [ ! -f config/couchdb.yml ]; then
  password=$(uuidgen | tr -d '-')
  username=$(uuidgen | tr -d '-')
  echo -e "[admins]\n$username = $password" > /etc/couchdb/local.d/rapidftr-security.ini
  bundle exec rake db:create_couchdb_yml[$username,$password]
fi

# Precompile assets
bundle exec rake assets:clobber assets:precompile

# Seed database
runsv /etc/service/couchdb &
runsv /etc/service/solr &
sleep 5

bundle exec rake db:seed db:migrate
bundle exec rake sunspot:reindex

sv shutdown couchdb
sv shutdown solr
sleep 5
killall java
