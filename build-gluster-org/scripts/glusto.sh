#!/bin/bash
/opt/qa/centos-ci/scripts/jenkins-trigger-console.py -j $REMOTE_JENKINS_JOB -u https://ci.centos.org -p "NODE_COUNT=9,BRANCH=$GERRIT_REFSPEC,GERRIT_REF={glustoversion},BUILD_CAUSE=$JOB_NAME-$BUILD_DISPLAY_NAME" --encoding text
