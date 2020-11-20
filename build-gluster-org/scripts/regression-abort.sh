#!/bin/bash

UNIQUE_ID="${JOB_NAME}-${BUILD_ID}"
filename="glusterfs-logs-${UNIQUE_ID}.tgz"
sudo -E tar -czf "${filename}" /var/log/glusterfs /var/log/messages*;
scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i "$LOG_KEY" "${filename}" "_logs-collector@logs.aws.gluster.org:/var/www/glusterfs-logs/$JOB_NAME-$BUILD_ID.tgz" || true
echo "Logs are archived in https://logs.aws.gluster.org/$JOB_NAME-$BUILD_ID.tgz"
# do clean up after a regression test suite is run
sudo -E bash /opt/qa/cleanup.sh
# make sure that every file/diretory belongs to jenkins
sudo chown -R jenkins:jenkins $WORKSPACE

sudo reboot