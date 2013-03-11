SET PATH=%PATH%;"%*"
SET RAILS_ENV=standalone
cd App
bundle exec rake windows:reset

