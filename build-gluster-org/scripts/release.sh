#!/bin/bash
set -xe

./autogen.sh;
./configure --enable-fusermount --enable-gnfs
make dist
sha512sum glusterfs-$RELEASE_VERSION.tar.gz > glusterfs-$RELEASE_VERSION.sha512sum
