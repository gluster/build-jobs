#!/bin/bash

ARCHIVE_BASE="/archives"
ARCHIVED_LOGS="logs"
UNIQUE_ID="${JOB_NAME}-${BUILD_ID}"
SERVER=$(hostname)

filename="${ARCHIVED_LOGS}/glusterfs-logs-${UNIQUE_ID}.tgz"
sudo -E tar -czf "${ARCHIVE_BASE}/${filename}" /var/log/glusterfs /var/log/messages*;
echo "Logs archived in http://${SERVER}/${filename}"
# do clean up after a regression test suite is run
sudo -E bash /opt/qa/cleanup.sh
# make sure that every file/diretory belongs to jenkins
sudo chown -R jenkins:jenkins $WORKSPACE

sudo reboot
