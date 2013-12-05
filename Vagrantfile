# This file is for running the RapidFTR Rails development virtual machine.
# For instructions, see
# https://github.com/rapidftr/RapidFTR/wiki/Using-a-VM-for-development
# For documentation on this file format, see
# http://vagrantup.com/docs/vagrantfile.html
Vagrant::Config.run do |config|
  config.vm.box = "rapidftr"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"
  
  config.vm.forward_port 3000, 3000
  config.vm.forward_port 5984, 5984
  
  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "core"
    chef.add_recipe "couchdb"
    chef.add_recipe "rvm"
    chef.add_recipe "ruby"
    chef.add_recipe "xvfb"
    chef.add_recipe "firefox"
  end
end
