#!/bin/sh
set -e
MOCK_CHROOT=fedora-30-x86_64

MOCK="sudo mock -r $MOCK_CHROOT --config-opts=dnf_warning=False --config-opts=use_bootstrap_container=True"

$MOCK --clean
$MOCK --init
$MOCK --install rubygem-bundler ruby-devel curl-devel make gcc gcc-c++ ImageMagick patch zlib-devel tar git rubygem-bigdecimal
$MOCK --copyin $WORKSPACE /src
$MOCK --enable-network --chroot "cd /src && bundle install && bundle exec middleman build --verbose"
$MOCK --copyout /src/build/ $WORKSPACE/build
$MOCK --clean

sudo chown -R jenkins:jenkins build
scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i "$LOG_KEY" -r build/. _bits-gluster@http.int.rht.gluster.org:/var/www/glusterfs-planet
