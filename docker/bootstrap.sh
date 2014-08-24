#!/bin/bash
set -xe

export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive
minimal_apt_get_install='apt-get install -y --no-install-recommends'

# PAM conflicts with users on Host machine!
#   https://github.com/dotcloud/docker/issues/6345#issuecomment-49245365
#   This workaround is required temporarily, can be removed after
#   Docker Hub kernel is upgraded or issue is fixed
ln -s -f /bin/true /usr/bin/chfn
alias adduser='useradd'

echo "path-exclude /usr/share/doc/*" > /etc/dpkg/dpkg.cfg.d/01_nodoc
echo "path-include /usr/share/doc/*/copyright" >> /etc/dpkg/dpkg.cfg.d/01_nodoc
echo "path-exclude /usr/share/man/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc
echo "path-exclude /usr/share/groff/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc
echo "path-exclude /usr/share/info/*" >> /etc/dpkg/dpkg.cfg.d/01_nodoc

apt-get update
$minimal_apt_get_install build-essential git libxml2-dev libxslt1-dev zlib1g-dev imagemagick openjdk-7-jre-headless uuid-runtime couchdb nodejs

apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /build/ $0
