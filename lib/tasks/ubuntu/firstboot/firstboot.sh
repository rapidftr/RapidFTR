#!/bin/bash -xe
# Install all necessary software when booting LXC container

apt-get update
apt-get install --force-yes -y python-software-properties
add-apt-repository -y ppa:nilya/couchdb-1.3
add-apt-repository -y ppa:brightbox/ruby-ng
apt-get update
apt-get install --force-yes -y libxml2-dev libxslt1-dev build-essential git openjdk-7-jdk imagemagick openssh-server zlib1g-dev couchdb nginx-full ruby1.9.3 passenger-common1.9

echo 'gem: --no-ri --no-rdoc' > /etc/gemrc
gem install bundler -v 1.3.5

mkdir /etc/nginx/ssl
cp /firstboot/server.* /etc/nginx/ssl
cp /firstboot/couchdb.ini /etc/couchdb/local.d/rapidftr.ini
cp /firstboot/nginx.conf /etc/nginx/conf.d/rapidftr.conf

chown couchdb:couchdb /etc/couchdb/local.d/rapidftr.ini
chown ubuntu:ubuntu /srv
chown ubuntu:ubuntu /etc/nginx/sites-enabled

/etc/init.d/couchdb restart
/etc/init.d/nginx restart
apt-get clean

rm -Rf /firstboot
rm /etc/init/firstboot.conf

halt
