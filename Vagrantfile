# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

['vagrant-librarian-chef', 'vagrant-omnibus'].each do |plugin|
  if !Vagrant.has_plugin?(plugin)
    puts "The #{plugin} plugin is required. Please install it with:\n$ vagrant plugin install #{plugin}"
    exit
  end
end

# Make sure you have run "git submodule init && git submodule update" to pull the infrastructure code
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider 'virtualbox' do |vbox|
    vbox.memory = 1024
    vbox.cpus = 2
  end

  config.librarian_chef.cheffile_dir = "infrastructure"
  config.omnibus.chef_version = "11.12.8"

  config.vm.define 'dev', primary: true do |dev|
    dev.vm.box = 'ubuntu/trusty32'
    dev.vm.network 'forwarded_port', guest: 3000, host: 3000
    dev.vm.network 'forwarded_port', guest: 5984, host: 5984
    dev.vm.network 'forwarded_port', guest: 8983, host: 8983
    dev.ssh.forward_x11 = true
    dev.ssh.forward_agent = true
    dev.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = [ 'infrastructure/cookbooks', 'infrastructure/site-cookbooks' ]
      chef.roles_path = 'infrastructure/roles'
      chef.add_role 'development'
      chef.verbose_logging = true
    end
    dev.vm.synced_folder 'tmp/vagrant/dev/apt', '/var/cache/apt/archives', create: true
    dev.vm.synced_folder 'tmp/vagrant/dev/gems', '/usr/local/rvm/gems/ruby-2.1.2@rapidftr/cache', create: true, mount_options: ['dmode=777', 'fmode=666']
    dev.vm.synced_folder 'tmp/vagrant/dev/rubies', '/usr/local/rvm/archives', create: true, mount_options: ['dmode=777', 'fmode=666']
  end

  config.vm.define 'prod', autostart: false do |prod|
    prod.vm.box = 'ubuntu/trusty64'
    prod.vm.network 'forwarded_port', guest: 80, host: 8080
    prod.vm.network 'forwarded_port', guest: 443, host: 8443
    prod.vm.network 'forwarded_port', guest: 5984, host: 5984
    prod.vm.network 'forwarded_port', guest: 6984, host: 6984
    prod.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = [ 'infrastructure/cookbooks', 'infrastructure/site-cookbooks' ]
      chef.roles_path = 'infrastructure/roles'
      chef.add_role 'production'
      chef.verbose_logging = true
    end
    prod.vm.synced_folder 'tmp/vagrant/prod/apt', '/var/cache/apt/archives', create: true
    prod.vm.synced_folder 'tmp/vagrant/prod/gems2.1.0', '/srv/rapidftr/localhost/shared/gems/ruby/2.1.0/cache', create: true, mount_options: ['dmode=777', 'fmode=666']
    prod.vm.synced_folder 'tmp/vagrant/prod/gems2.1.2', '/srv/rapidftr/localhost/shared/gems/ruby/2.1.2/cache', create: true, mount_options: ['dmode=777', 'fmode=666']
  end

end
