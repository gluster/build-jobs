#!/bin/bash

ARCHIVE_BASE="/archives"
ARCHIVED_LOGS="logs"
UNIQUE_ID="${JOB_NAME}-${BUILD_ID}"
SERVER=$(hostname)

filename="${ARCHIVED_LOGS}/glusterfs-logs-${UNIQUE_ID}.tgz"
sudo -E bash tar -czf "${ARCHIVE_BASE}/${filename}" /var/log/glusterfs /var/log/messages*;
echo "Logs archived in http://${SERVER}/${filename}"
sudo reboot
