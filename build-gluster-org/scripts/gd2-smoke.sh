#!/bin/bash

set -e

JDIRS="/var/log/glusterfs /var/lib/glusterd /var/run/gluster /build"
sudo rm -rf $JDIRS
sudo mkdir -p $JDIRS || true
echo Return code = $?
sudo chown -RH jenkins:jenkins $JDIRS
echo Return code = $?
sudo chmod -R 755 $JDIRS
echo Return code = $?

# build the glusterfs source code
/opt/qa/build.sh

# run gd2 tests script
/opt/qa/glusterd2-test.sh
