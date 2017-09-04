#!/bin/sh
set -e
virtualenv env
env/bin/pip install -e git+git://git.openstack.org/openstack-infra/jenkins-job-builder#egg=jenkins_jobs
env/bin/jenkins-jobs --conf $JJB_CONFIG update build-gluster-org/jobs
