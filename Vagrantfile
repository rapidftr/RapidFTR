# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hashicorp/precise32"

  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 5984, host: 5984

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "core"
    chef.add_recipe "couchdb"
    chef.add_recipe "rvm"
    chef.add_recipe "xvfb"
    chef.add_recipe "firefox"
    chef.add_recipe "seed"
    chef.log_level = "debug"
    chef.verbose_logging = true
  end

  # Sync apt and gem caches, so that they don't re-download everytime
  config.vm.synced_folder 'tmp/vagrant/apt', '/var/cache/apt/archives', create: true
  config.vm.synced_folder 'tmp/vagrant/rubies', '/usr/local/rvm/archives', create: true
  config.vm.synced_folder 'tmp/vagrant/gems', '/usr/local/rvm/gems/ruby-1.9.3-p392@rapidftr/cache', create: true

end
