#!/bin/sh
set -e
virtualenv env
env/bin/pip install jenkins-job-builder
# hack to update the certificate store
# since that job is still running on python2, the pip installed requests module pull certifi, who has a older CA database
# so it fail since the root CA of lets encrypt expired on 1st october 2021
cp -f /etc/pki/tls/cert.pem  env/lib/python2.7/site-packages/certifi/cacert.pem
env/bin/jenkins-jobs --conf $JJB_CONFIG update build-gluster-org/jobs
