# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "dev", primary: true, autostart: false do |dev|
    dev.vm.box = "hashicorp/precise32"
    dev.vm.network "forwarded_port", guest: 3000, host: 3000
    dev.vm.network "forwarded_port", guest: 5984, host: 5984
    dev.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = 'chef/cookbooks'
      chef.roles_path = 'chef/roles'
      chef.add_role 'development'
      chef.verbose_logging = true
    end
  end

  config.vm.define "prod", autostart: false do |prod|
    prod.vm.box = "hashicorp/precise64"
    prod.vm.network "forwarded_port", guest: 80, host: 8080
    prod.vm.network "forwarded_port", guest: 443, host: 8443
    prod.vm.network "forwarded_port", guest: 5984, host: 5984
    prod.vm.network "forwarded_port", guest: 6984, host: 6984
    prod.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = 'chef/cookbooks'
      chef.roles_path = 'chef/roles'
      chef.add_role 'production'
      chef.verbose_logging = true
    end
  end

  # Sync apt and gem caches, so that they don't re-download everytime
  config.vm.synced_folder 'tmp/vagrant/apt', '/var/cache/apt/archives', create: true
  config.vm.synced_folder 'tmp/vagrant/rubies', '/usr/local/rvm/archives', create: true
  config.vm.synced_folder 'tmp/vagrant/gems', '/usr/local/rvm/gems/ruby-1.9.3-p392@rapidftr/cache', create: true

end
