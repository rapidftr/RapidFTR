SET PATH=%PATH%;"%*"
SET RAILS_ENV=standalone
cd App
bundle exec rake db:create_couch_sysadmin couchdb:create db:seed db:migrate
