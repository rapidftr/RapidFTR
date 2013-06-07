#!/bin/bash -xe
lxc_dev=/var/lib/lxc/rapidftr_lxc/rootfs/dev
mv $lxc_dev $lxc_dev.old || echo
mkdir -p $lxc_dev
mknod -m 666 $lxc_dev/null c 1 3
mknod -m 666 $lxc_dev/zero c 1 5
mknod -m 666 $lxc_dev/random c 1 8
mknod -m 666 $lxc_dev/urandom c 1 9
mkdir -m 755 $lxc_dev/pts
mkdir -m 1777 $lxc_dev/shm
mknod -m 666 $lxc_dev/tty c 5 0
mknod -m 600 $lxc_dev/console c 5 1
mknod -m 666 $lxc_dev/tty0 c 4 0
mknod -m 666 $lxc_dev/full c 1 7
mknod -m 600 $lxc_dev/initctl p
mknod -m 666 $lxc_dev/ptmx c 5 2
