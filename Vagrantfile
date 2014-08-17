# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

# Check required plugins
REQUIRED_PLUGINS = %w(vagrant-omnibus vagrant-faster)
exit unless REQUIRED_PLUGINS.all? { |plugin|
  Vagrant.has_plugin?(plugin) || (
    puts "The #{plugin} plugin is required. Please install it with:"
    puts "$ vagrant plugin install #{plugin}"
    false
  )
}

# Update infrastructure
unless Dir['infrastructure/site-cookbooks']
  system('git submodule update --init')
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = 'ubuntu/trusty32'
  config.vm.network 'forwarded_port', :guest => 3000, :host => 3000
  config.vm.network 'forwarded_port', :guest => 5984, :host => 5984
  config.vm.network 'forwarded_port', :guest => 8983, :host => 8983
  config.ssh.forward_x11 = true
  config.ssh.forward_agent = true

  config.omnibus.chef_version = "11.12.8"
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ['infrastructure/site-cookbooks']
    chef.add_recipe 'rapidftr-dev'
    chef.verbose_logging = true
  end

  config.vm.provision :shell, :run => 'always', :privileged => false, :inline => <<-SCRIPT
    cd /vagrant && bundle exec rake sunspot:solr:start
  SCRIPT

  config.vm.synced_folder 'tmp/vagrant/dev/apt', '/var/cache/apt/archives', :create => true
  config.vm.synced_folder 'tmp/vagrant/dev/gems', '/var/lib/gems/2.1.0/cache', :create => true, :mount_options => ['dmode=777', 'fmode=666']

end
