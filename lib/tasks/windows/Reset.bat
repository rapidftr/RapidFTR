SET PATH=%PATH%;"%*"
SET RAILS_ENV=standalone
cd App
call bundle install
bundle exec rake db:create_couch_sysadmin[rapidftr,rapidftr] couchdb:create db:migrate db:seed
