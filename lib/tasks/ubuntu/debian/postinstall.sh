#!/bin/bash

INSTALL_DIR=/usr/lib/rapidftr/

cd $INSTALL_DIR
cp ./lib/task/ubuntu/debian/rapidftr.sh /usr/bin/rapidftrserver
export RAILS_ENV=production
bundle exec rake couchdb:create db:seed app:run_with_thin
