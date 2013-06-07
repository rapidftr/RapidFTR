#!/bin/bash -xe
# Deploy RapidFTR to LXC container

while true
do
  case "$1" in
  -v|--version) version=$2; shift 2;;
  *)         break ;;
  esac
done

version=${version?'--version is required'}
if [ "$version" == *dev ]; then
  branch="master"
elif [ "$version" == "master" ]; then
  branch="master"
else
  branch="release-$version"
fi

lxc-start -n rapidftr_lxc -d
lxc-wait -n rapidftr_lxc -s RUNNING
sleep 10

lxc_dir=/var/lib/lxc/rapidftr_lxc
lxc_host=$(cat /var/lib/misc/dnsmasq.leases | grep rapidftr_lxc | cut -d' ' -f3)
bundle exec cap deploy -S deploy_server=$lxc_host -S deploy_user=ubuntu -S rails_env=production -S http_port=80 -S https_port=443 -S solr_port=8983 -S couchdb_host=localhost -S couchdb_username=rapidftr -S couchdb_password=rapidftr -S nginx_site_conf=/etc/nginx/sites-enabled -S branch=$branch deploy

lxc-stop -n rapidftr_lxc
lxc-wait -n rapidftr_lxc -s STOPPED

cp lib/tasks/ubuntu/firstboot/rapidftr.conf $lxc_dir/rootfs/etc/init/
