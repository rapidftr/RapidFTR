#
# Cookbook Name:: core
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# 'apt-get update' is required before installing packages
execute "apt-get-update" do
  command "apt-get update"
end

package "build-essential" do
  action :install
end

package "git" do
  action :install
end

package "openjdk-7-jdk" do
  action :install
end

package "libxml2-dev" do
  action :install
end

package "libxslt1-dev" do
  action :install
end

package "imagemagick" do
  action :install
end
