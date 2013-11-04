#
# Cookbook Name:: couchdb
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "python-software-properties" do
  action :install
  options "--assume-yes"
end

execute "apt-add-repository-couchdb" do
  command "apt-add-repository ppa:nilya/couchdb-1.3"
  not_if "dpkg --get-selections | grep -q 'couchdb'"
end

# Requires a unique name from other recipes in order to run
execute "apt-get-update-couchdb" do
  command "apt-get update"
  not_if "dpkg --get-selections | grep -q 'couchdb'"
end

package "couchdb" do
  action :install
end

# Bind CouchDB to the correct port so that it can be accessed from the host
cookbook_file "/etc/couchdb/local.ini" do
  source "local.ini"
  owner "couchdb"
  group "couchdb"
  mode 0664
end

# Make CouchDB use the updated local.ini file
service "couchdb" do
  action :reload
  reload_command "service couchdb force-reload"
  not_if "netstat -an | grep -q '0\.0\.0\.0:5984'"
end
