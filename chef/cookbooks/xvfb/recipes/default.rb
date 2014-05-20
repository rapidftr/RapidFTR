#
# Cookbook Name:: xvfb
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "xfonts-cyrillic" do
  action :install
end

package "xfonts-100dpi" do
  action :install
end

package "xfonts-75dpi" do
  action :install
end

package "xfonts-scalable" do
  action :install
end

package "xvfb" do
  action :install
end

execute "set-display" do
  command "echo 'DISPLAY=:99' >> /etc/environment"
  not_if "cat /etc/environment | grep -q '^DISPLAY=:99$'"
end

cookbook_file "/etc/init.d/xvfb" do
  source "xvfb"
  owner "root"
  group "root"
  mode 0755
end

execute "update-rc.d-xvfb" do
  command "update-rc.d xvfb defaults"
end

execute "start-xvfb" do
  command "/etc/init.d/xvfb start"
  not_if "ps ax | grep -q '[X]vfb'"
end
