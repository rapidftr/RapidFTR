SET PATH=%PATH%;"%*"
SET RAILS_ENV=production
cd App
bundle install --deployment
bundle exec rake windows:reset
