SET RAILS_ENV=standalone
cd App
start /B "bundle exec rake scheduler:run"
start /B "bundle exec rake sunspot:solr:run"
bundle exec rails server
