#!/bin/sh
set -e
virtualenv env
env/bin/pip install jenkins-job-builder
env/bin/jenkins-jobs --conf $JJB_CONFIG update build-gluster-org/jobs
