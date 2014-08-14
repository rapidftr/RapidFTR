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
  openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj "/C=XX/ST=FIXME/L=FIXME/O=FIXME/CN=FIXME" -keyout /data/ssl/certificate.key -out /data/ssl/certificate.crt
fi
chown -R root:root /data/ssl
chmod 0700 /data/ssl
chmod 0600 /data/ssl/*

echo "Securing CouchDB..."
cd /rapidftr
if [ ! -f config/couchdb.yml ]; then
  password=$(uuidgen | tr -d '-')
  username=$(uuidgen | tr -d '-')
  echo -e "[admins]\n$username = $password" > /etc/couchdb/local.d/rapidftr-security.ini
  bundle exec rake db:create_couchdb_yml[$username,$password]
fi

echo "Compiling assets..."
bundle exec rake assets:clobber assets:precompile

echo "Seeding and migrating database..."
runsv /etc/service/couchdb &
sleep 5
bundle exec rake db:seed db:migrate

echo "Reindexing search..."
runsv /etc/service/solr &
sleep 5
bundle exec rake sunspot:reindex

echo "Normal system boot will now start..."
sv shutdown couchdb
sv shutdown solr
sleep 5
killall java
