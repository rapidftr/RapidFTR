SET PATH=%PATH%;"%*"
SET RAILS_ENV=standalone
cd App
gem install vendor/windows/ruby/1.8/cache/rubygems-update-1.8.25.gem --no-ri --no-rdoc
gem install vendor/windows/ruby/1.8/cache/bundler-1.2.5.gem --no-ri --no-rdoc
update_rubygems
bundle install
bundle exec rake db:create_couch_sysadmin couchdb:create db:seed db:migrate
