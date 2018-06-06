#!/bin/sh

MAX_ATTEMPTS=3
set -e

# create and activate virtual env
virtualenv env
source env/bin/activate

# create SSH key pair of 4096 bits to use it for instances at Rackspace
ssh-keygen -f ${WORKSPACE}/key -t rsa -b 4096

# Install pyrax dependency
pip install pyrax
/opt/qa/distributed-tests/rackspace-server-manager.py create -n ${MACHINES_COUNT}

for retry in `seq 1 $MAX_ATTEMPTS`
do
  ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts --private-key=key /opt/qa/distributed-tests/distributed-server.yml -u root
  ret=$?
  if [ $ret -eq 0 ]; then
    break
  fi
  echo 'Attempting to run again...'
done

# run the script of distributed-test
../scripts/run-distributed-test.py
ret=$?
if [ $ret -eq 0 ]; then
  # Create tar file from all the failed test log files generated in /tmp
  tar -czf $WORKSPACE/failed-test-logs.tgz /tmp/*.log

  # if test runs are successful, delete all the machines
  /opt/qa/distributed-tests/rackspace-server-manager.py delete
fi
