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
  command "apt-add-repository -y ppa:brightbox/passenger-nginx"
  not_if "dpkg --get-selections | grep -q 'nginx-full'"
end

package "nginx-full" do
  action :install
end

cookbook_file "/etc/nginx/conf.d/passenger.conf" do
  source "passenger.conf"
  owner "root"
  group "root"
  mode 0664
end
