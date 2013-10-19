#
# Cookbook Name:: firefox
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

# Install Firefox 20 as the latest version is not compatible with the Selenium WebDriver version
execute "apt-add-repository-firefox" do
  command "apt-add-repository 'deb http://us.archive.ubuntu.com/ubuntu/ lucid-security main'"
  not_if "dpkg --get-selections | grep -q 'firefox'"
end

# Requires a unique name from other recipes in order to run
execute "apt-get-update-firefox" do
  command "apt-get update"
  not_if "dpkg --get-selections | grep -q 'firefox'"
end

package "firefox" do
  action :install
  version "20.0+build1-0ubuntu0.10.04.3"
end
