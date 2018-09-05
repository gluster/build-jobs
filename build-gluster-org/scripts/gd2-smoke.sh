#!/bin/bash

set -e

JDIRS="/var/log/glusterfs /var/lib/glusterd /var/lib/glusterd/groups/virt /var/run/gluster /d /d/archived_builds /d/backends /d/build /d/logs /home/jenkins/root /build/*"
sudo mkdir -p $JDIRS
echo Return code = $?
sudo chown -RH jenkins:jenkins $JDIRS
echo Return code = $?
sudo chmod -R 755 $JDIRS
echo Return code = $?

# build the glusterfs source code
/opt/qa/build.sh

# run gd2 tests script
/opt/qa/glusterd2-test.sh
