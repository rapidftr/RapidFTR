SET PATH=%PATH%;"%*"
SET RAILS_ENV=standalone
cd App
call bundle install --local --no-cache
bundle exec rake db:create_couch_sysadmin[rapidftr,rapidftr] couchdb:create db:seed db:migrate
