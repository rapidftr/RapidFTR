# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

if !Vagrant.has_plugin?('vagrant-omnibus')
  puts "The vagrant-omnibus plugin is required. Please install it with:"
  puts "$ vagrant plugin install vagrant-omnibus"
  exit
end

if !Dir['infrastructure/site-cookbooks']
  system('git submodule update --init')
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = 'ubuntu/trusty32'
  config.vm.network 'forwarded_port', guest: 3000, host: 3000
  config.vm.network 'forwarded_port', guest: 5984, host: 5984
  config.vm.network 'forwarded_port', guest: 8983, host: 8983
  config.ssh.forward_x11 = true
  config.ssh.forward_agent = true

  config.omnibus.chef_version = "11.12.8"
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = [ 'infrastructure/site-cookbooks' ]
    chef.add_recipe 'rapidftr-dev'
    chef.verbose_logging = true
  end

  config.vm.synced_folder 'tmp/vagrant/dev/apt', '/var/cache/apt/archives', create: true
  config.vm.synced_folder 'tmp/vagrant/dev/gems', '/var/lib/gems/2.1.0/cache', create: true, mount_options: ['dmode=777', 'fmode=666']

  config.vm.provider "virtualbox" do |vbox|
    host = RbConfig::CONFIG['host_os']

    cpus = 1
    mem = 768
    begin
      if host =~ /darwin/
        cpus = `sysctl -n hw.ncpu`.to_i
        mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024
      elsif host =~ /linux/
        cpus = `nproc`.to_i
        mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024
      end

      # Give VM 1/4 system memory & access to half of cpu cores on the host
      cpus = cpus / 2 if cpus > 1
      mem  = mem / 4  if mem > 2048
    rescue
      puts "Unable to detect system memory/CPU, please edit vagrant config or set VAGRANT_SAFE_MODE=true"
    end

    vbox.memory = mem
    vbox.cpus = cpus
  end unless ENV['VAGRANT_SAFE_MODE'] == 'true'

end
