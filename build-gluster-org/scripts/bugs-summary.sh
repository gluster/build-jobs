#!/bin/sh
./run-report.sh

scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i "$LOG_KEY" _bits-gluster@http.int.rht.gluster.org:/var/www/glusterfs-bugs
