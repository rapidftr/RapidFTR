#!/bin/bash -xe
# Build packaging environment

while true
do
  case "$1" in
  -v|--version) version=$2; shift 2;;
  *)         break ;;
  esac
done

version=${version?'--version is required'}
which fpm || gem install fpm

lxc-stop -n rapidftr_lxc || echo 'RapidFTR already stopped'

package_dir=tmp/deb
rm -rf $package_dir || echo

mkdir -p $package_dir/etc/init
cp lib/tasks/ubuntu/rapidftr.conf $package_dir/etc/init/

mkdir -p $package_dir/var/lib/lxc
mv /var/lib/lxc/rapidftr_lxc $package_dir/var/lib/lxc/

lxc_root=$package_dir/var/lib/lxc/rapidftr_lxc/rootfs
(find $lxc_root/dev -type c -or -type b -or -type p | xargs rm) || echo
rm -rf $lxc_root/tmp/*
rm -rf $lxc_root/var/tmp/*

fpm -s dir -t deb -n rapidftr --deb-compression xz -v $version -C tmp/deb --after-install lib/tasks/ubuntu/deb-after-install.sh --after-remove lib/tasks/ubuntu/deb-after-remove.sh .
