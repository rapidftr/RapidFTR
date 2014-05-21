#
# Cookbook Name:: passenger
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

execute "apt-add-repository-ruby" do
  command "apt-add-repository -y ppa:brightbox/ruby-ng"
  not_if "dpkg --get-selections | grep -q 'nginx-full'"
  notifies :run, "execute[apt-get-update]", :immediately
end

package "nginx-full" do
  action :install
end

package "passenger-common1.9" do
  action :install
end

cookbook_file "/etc/nginx/conf.d/passenger.conf" do
  source "passenger.conf"
  owner "root"
  group "root"
  mode 0664
end

service "nginx" do
  action :enable
end
