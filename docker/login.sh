#!/usr/bin/env bash

cd /rapidftr

if [ "RAILS_ENV" = "development" ]; then
	rm -Rf /rapidftr/.bundle 
	bundle install --jobs 4 --path vendor/
fi

runsv /etc/service/couchdb &
sleep 2

bundle exec rake db:create_couchdb_yml[rapidftr,rapidftr]
bundle exec rake db:seed db:migrate
bundle exec rake assets:clean assets:precompile

sv shutdown couchdb
sleep 2

chown -R www-data:www-data /rapidftr



