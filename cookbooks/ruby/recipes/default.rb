#
# Cookbook Name:: ruby
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

file "/etc/gemrc" do
  owner "root"
  group "root"
  mode 0664
  action :create
  content "gem: --no-ri --no-rdoc"
end

execute "apt-add-repository-ruby" do
  command "apt-add-repository -y ppa:brightbox/ruby-ng"
  not_if "dpkg --get-selections | grep -q 'ruby1.9.3'"
end

package "ruby1.9.3" do
  action :install
end

execute "bundler" do
  command "gem install bundler -v 1.3.5"
  not_if "which bundler"
end
