#!/bin/bash

INSTALL_DIR=/usr/lib/rapidftr/

cd $INSTALL_DIR
cp ./lib/tasks/ubuntu/debian/rapidftr.sh /usr/bin/rapidftrserver

gem install ./vendor/bundle/ruby/1.8/cache/bundler-1.2.3.gem

echo "---" > .bundle/config
echo "BUNDLE_DISABLE_SHARED_GEMS: \"1\"" >> .bundle/config
echo "BUNDLE_PATH: vendor/bundle/" >> .bundle/config

export RAILS_ENV=production
bundle exec rake couchdb:create db:seed app:run_with_thin
