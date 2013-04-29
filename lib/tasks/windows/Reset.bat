SET PATH=%PATH%;"%*"
SET RAILS_ENV=standalone
cd App
call gem install vendor/windows/ruby/1.8/cache/rubygems-update-1.8.25.gem --no-ri --no-rdoc
call gem install vendor/windows/ruby/1.8/cache/bundler-1.2.5.gem --no-ri --no-rdoc
call update_rubygems
call bundle install
bundle exec rake db:create_couch_sysadmin[rapidftr,rapidftr] couchdb:create db:migrate db:seed
