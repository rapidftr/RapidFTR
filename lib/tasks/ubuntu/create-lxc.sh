#!/bin/bash -xe
# Create RapidFTR LXC Container and install dependencies in it

while true
do
  case "$1" in
  --ssl-key) ssl_key=$2; shift 2;;
  --ssl-crt) ssl_crt=$2; shift 2;;
  --ssh-key) ssh_key=$2; shift 2;;
  --ssh-crt) ssh_crt=$2; shift 2;;
  *)         break ;;
  esac
done

ssl_crt=${ssl_crt?'--ssl-crt is required'}
ssl_key=${ssl_key?'--ssl-key is required'}
ssh_crt=${ssh_crt?'--ssh-crt is required'}
ssh_key=${ssh_key?'--ssh-key is required'}

which lxc-create || apt-get install --force-yes -y lxc
lxc-create -t ubuntu -n rapidftr_lxc --fssize 2G -- --auth-key $ssh_crt
lxc_dir=/var/lib/lxc/rapidftr_lxc

cp -r lib/tasks/ubuntu/firstboot $lxc_dir/rootfs/
cp lib/tasks/ubuntu/firstboot/firstboot.conf $lxc_dir/rootfs/etc/init/firstboot.conf
cp $ssl_key $lxc_dir/rootfs/firstboot/server.key
cp $ssl_crt $lxc_dir/rootfs/firstboot/server.crt

lxc-start -n rapidftr_lxc -d
lxc-wait -n rapidftr_lxc -s RUNNING

echo "Waiting for LXC Container to be setup..."
echo "Logs are present in $lxc_dir/rootfs/var/log/upstart/firstboot.log"
tail --follow=name --retry $lxc_dir/rootfs/var/log/upstart/firstboot.log --pid=$$ &
lxc-wait -n rapidftr_lxc -s STOPPED
