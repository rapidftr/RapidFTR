#
# Cookbook Name:: rvm
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "curl" do
  action :install
end

execute "download-install-rvm" do
  command "su -l vagrant -c 'curl -L https://get.rvm.io | bash'"
  not_if { ::File.exists? "/home/vagrant/.rvm" }
end
