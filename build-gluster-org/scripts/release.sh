#!/bin/bash
set -xe
./autogen.sh;
./configure --enable-fusermount --enable-gnfs --disable-linux-io_uring
make dist
sha512sum glusterfs-$RELEASE_VERSION.tar.gz > glusterfs-$RELEASE_VERSION.sha512sum
if [[ "$PUBLISH_ARCHIVES" == "true" ]]; then
    scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i $BITS_KEY glusterfs-$RELEASE_VERSION.tar.gz glusterfs-$RELEASE_VERSION.sha512sum _bits-gluster@http.int.rht.gluster.org:/var/www/bits/pub/gluster/glusterfs/src/
fi
