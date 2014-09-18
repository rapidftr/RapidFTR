#!/bin/bash
set -xe

apt-get install -y --no-install-recommends git


gitbook_build() {
  mkdir -p $TARGET
  gitbook build -o $TARGET/deploy $SRC/deploy
  gitbook build -o $TARGET/admin $SRC/admin
  gitbook build -o $TARGET/use $SRC/use
  gitbook build -o $TARGET/api $SRC/api
  cp $SRC/index.html $TARGET/
}

# Build master
SRC=/tmp/rapidftrguide/master TARGET=/tmp/rapidftrguide/build GUIDE=/rapidftr/public/guide

git clone --quiet --branch=master git://github.com/rapidftr/guide.git $SRC

ls $SRC
cd $SRC
npm install gitbook -g
npm install --unsafe-perm $SRC

gitbook_build

mkdir $GUIDE
cp -R $TARGET/* $GUIDE
apt-get clean
rm -rf /tmp/* $0
