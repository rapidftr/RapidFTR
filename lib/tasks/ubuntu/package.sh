#!/bin/bash -xe
# Usage (from RapidFTR folder, run):
#   sudo apt-get install --yes ruby1.8 ruby1.8-dev rubygems1.8 libxml2-dev libxslt1-dev build-essential git openssh-server
#   sudo gem install bundler -v 1.3.1
#   sudo gem install fpm
#   sudo lib/tasks/ubuntu/package.sh

echo 'install: --no-ri --no-rdoc' >> /etc/gemrc
echo 'update: --no-ri --no-rdoc'  >> /etc/gemrc

BASEDIR=`pwd`
# mkdir -p tmp/bundler

mkdir -p /usr/lib/rapidftr
rsync -avz --exclude features --exclude '.git' --exclude 'tmp' --exclude 'log' --exclude '.bundle' --exclude '*.deb' ./ /usr/lib/rapidftr/

cd /usr/lib/rapidftr
chown -R root:root .

# rm -Rf .bundle
# ln -s $BASEDIR/tmp/bundler vendor/bundle

# rm Gemfile.lock
bundle install --path=/usr/lib/rapidftr/vendor/bundle/
gem install bundler -v 1.3.1 --install-dir=vendor/bundle/ruby/1.8/
fpm -s dir -t deb -n "rapidftr" -v 1.1 --after-install /usr/lib/rapidftr/lib/tasks/ubuntu/postinstall.sh --before-remove /usr/lib/rapidftr/lib/tasks/ubuntu/before_remove.sh /usr/lib/rapidftr

mv *.deb $BASEDIR/
