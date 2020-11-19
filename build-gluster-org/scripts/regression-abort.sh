#!/bin/bash

sudo -E tar -czf $WORKSPACE/glusterfs-logs.tgz /var/log/glusterfs /var/log/messages*;
echo "Logs are archived at Build artifacts: https://build.gluster.org/job/${JOB_NAME}/${UNIQUE_ID}"
# do clean up after a regression test suite is run
sudo -E bash /opt/qa/cleanup.sh
# make sure that every file/diretory belongs to jenkins
sudo chown -R jenkins:jenkins $WORKSPACE

sudo reboot
