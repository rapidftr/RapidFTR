#!/bin/bash

export INSTALL_DIR=/usr/lib/rapidftr/
export RAILS_ENV=standalone

ufw allow 5984
ufw allow 6984
ufw allow 8983

cd $INSTALL_DIR
gem install vendor/bundle/ruby/1.8/cache/bundler-1.3.1.gem --no-ri --no-rdoc

bundle exec rake db:create_couch_sysadmin

cp lib/tasks/ubuntu/rapidftr-server.sh /usr/bin/rapidftr-server
rapidftr-server start
