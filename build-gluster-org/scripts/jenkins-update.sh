#!/bin/sh
set -e
virtualenv-3 env
env/bin/pip3 install jenkins-job-builder
env/bin/jenkins-jobs --conf $JJB_CONFIG update build-gluster-org/jobs
