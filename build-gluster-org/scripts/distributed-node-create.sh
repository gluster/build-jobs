#!/bin/sh
set -e

# create and activate virtual env
virtualenv env
source env/bin/activate

# create SSH key pair of 4096 bits to use it for instances at Rackspace
ssh-keygen -f ${WORKSPACE}/key -t rsa -b 4096

# Install pyrax dependency
pip install pyrax
/opt/qa/distributed-tests/rackspace-server-manager.py create -n ${MACHINES_COUNT}
