#!/bin/sh
set -e
virtualenv env
env/bin/pip install -e git+https://opendev.org/jjb/jenkins-job-builder.git@775499547496777752fb606ac7121b44c6b1f2d9#egg=jenkins_jobs
env/bin/jenkins-jobs --conf $JJB_CONFIG update build-gluster-org/jobs
