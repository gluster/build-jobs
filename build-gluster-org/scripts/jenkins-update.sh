#!/bin/sh
set -e
virtualenv env
env/bin/pip install -e git+https://opendev.org/jjb/jenkins-job-builder.git#egg=jenkins_jobs
env/bin/jenkins-jobs --conf $JJB_CONFIG update build-gluster-org/jobs
