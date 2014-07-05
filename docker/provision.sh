#!/bin/bash
set -e
source /build/buildconfig
set -x

rm -rf /var/lib/apt/lists/*
apt-get update
$minimal_apt_get_install build-essential git libxml2-dev libxslt1-dev zlib1g-dev imagemagick python-software-properties openjdk-7-jre-headless couchdb

apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /build/
