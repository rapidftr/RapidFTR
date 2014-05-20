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

execute "install-rvm" do
  command "sudo sh -c 'curl -L https://get.rvm.io | bash -s -- --auto-dotfiles'"
  not_if { ::File.exists? "/usr/local/rvm/bin/rvm" }
end

execute "rvm-ruby-1.9.3" do
  command "sudo sh -c '/usr/local/rvm/bin/rvm install 1.9.3-p392'"
  not_if { ::File.exists? "/usr/local/rvm/rubies/ruby-1.9.3-p392/bin/ruby" }
end
