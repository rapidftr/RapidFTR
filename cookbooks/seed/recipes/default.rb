#
# Cookbook Name:: seed
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

group "rvm" do
  members "vagrant"
  append true
end

execute "bundle-install" do
  command "su vagrant -l -c 'cd /vagrant && bundle install'"
end

execute "copy-couch-config-yml-dev" do
  command "su vagrant -l -c 'cd /vagrant && bundle exec rake db:create_couchdb_yml[rapidftr,rapidftr]'"
end

execute "rake-app-migrate" do
  command "su vagrant -l -c 'cd /vagrant && bundle exec rake couchdb:create db:seed db:migrate'"
end

execute "sunspot-start" do
  command "su vagrant -l -c 'cd /vagrant && bundle exec rake sunspot:clean_start'"
end

execute "scheduler-start" do
  command "su vagrant -l -c 'cd /vagrant && bundle exec rake scheduler:restart'"
end
