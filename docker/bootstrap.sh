#!/bin/bash
set -e
source /build/buildconfig
set -x

# PAM conflicts with users on Host machine!
#   https://github.com/dotcloud/docker/issues/6345#issuecomment-49245365
#   This workaround is required temporarily, can be removed after
#   Docker Hub kernel is upgraded or issue is fixed
export DEBIAN_FRONTEND=noninteractive
ln -s -f /bin/true /usr/bin/chfn

rm -rf /var/lib/apt/lists/*
apt-get update
$minimal_apt_get_install build-essential git libxml2-dev libxslt1-dev zlib1g-dev imagemagick python-software-properties openjdk-7-jre-headless uuid-runtime couchdb uuid-runtime

apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /build/ $0
