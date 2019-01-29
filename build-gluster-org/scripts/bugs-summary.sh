#!/bin/sh
./run-report.sh

scp -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i "$LOG_KEY" -r gluster-bugs.html gluster-bugs.js bugs.json style.css _bits-gluster@http.int.rht.gluster.org:/var/www/glusterfs-bugs
