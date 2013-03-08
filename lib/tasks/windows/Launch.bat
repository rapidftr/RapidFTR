SET RAILS_ENV=standalone
cd App
start bundle exec rake scheduler:run
start bundle exec rake sunspot:solr:run
bundle exec rails server
