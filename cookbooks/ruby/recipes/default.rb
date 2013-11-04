#
# Cookbook Name:: ruby
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute "rvm-install-ruby" do
  command "su -l vagrant -c 'rvm install 1.9.3-p392 --patch railsexpress'"
end
