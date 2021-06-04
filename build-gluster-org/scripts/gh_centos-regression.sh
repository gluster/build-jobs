#!/bin/bash

MY_ENV=$(env | sort)
BURL=${BUILD_URL}consoleFull

function clear_exit() {
    # leave result file empty if there is no failure, in context of `comment-file` in ghprb plugin
    touch gluster_regression.txt
    # do clean up after a regression test suite is run
    sudo -E bash /opt/qa/cleanup.sh
    # make sure that every file/diretory belongs to jenkins
    sudo chown -R jenkins:jenkins $WORKSPACE
    RET="$1"
    exit $RET
}

# Display all environment variables in the debugging log
echo "Start time $(date)"
echo
echo "Display all environment variables"
echo "*********************************"
echo
echo "$MY_ENV"
echo

# use "7 and not "7" since RHEL use 7.6 while Centos use 7
grep -q 'VERSION_ID="7' /etc/os-release && export PYTHON=/usr/bin/python2.7

# Remove any gluster daemon leftovers from aborted runs
sudo -E bash /opt/qa/cleanup.sh

# protection for testing the script
[ -z $WORKSPACE ] && echo '$WORKSPACE not set, aborting' && exit 1

# Clean up the git repo
sudo rm -rf $WORKSPACE/.gitignore $WORKSPACE/*
sudo chown -R jenkins:jenkins $WORKSPACE
cd $WORKSPACE || exit 1
git reset --hard HEAD

# Clean up other Gluster dirs
sudo rm -rf /var/lib/glusterd/* /build/install /build/scratch >/dev/null 2>&1

# Remove the many left over socket files in /var/run
sudo rm -f /var/run/????????????????????????????????.socket >/dev/null 2>&1

# Remove GlusterFS log files from previous runs
sudo rm -rf /var/log/glusterfs/* /var/log/glusterfs/.cmd_log_history >/dev/null 2>&1

JDIRS="/var/log/glusterfs /var/lib/glusterd /var/run/gluster /d /d/archived_builds /d/backends /d/build /d/logs /home/jenkins/root"
sudo mkdir -p $JDIRS
sudo chown jenkins:jenkins $JDIRS
chmod 755 $JDIRS

# Skip tests for certain folders
SKIP=true
# find out diff between the default devel branch and HEAD
for file in $(git diff origin/${ghprbTargetBranch}..HEAD --name-only); do
    /opt/qa/is-ignored-file.py $file
    matched=$?
    if [ $matched -eq 1 ]; then
        SKIP=false
        break
    fi
done
if [[ "$SKIP" == true ]]; then
    echo "Patch only modifies ignored files. Skipping further tests"
    RET=0
    clear_exit "$RET"
fi

# Build Gluster
echo "Start time $(date)"
echo
echo "Build GlusterFS"
echo "***************"
echo
/opt/qa/build.sh
RET=$?
if [ $RET != 0 ]; then
    # Build failed, so abort early
    clear_exit "$RET"
fi
echo

TEST_ONLY=true
declare -a TEST_FILES
TEST_COUNT=0
for file in $(git diff origin/${ghprbTargetBranch}..HEAD --name-only); do
    if [[ $file =~ tests/.*\.t$ ]] ;then
        TEST_FILES[$TEST_COUNT]="$file"
        TEST_COUNT=$(( $TEST_COUNT + 1 ))
    else
        TEST_ONLY=false
    fi
done

# Run the regression test
echo "Start time $(date)"
echo
echo "Run the regression test"
echo "***********************"
echo
if [[ "$TEST_ONLY" == true ]]; then
    echo "This review only changes tests, running only the changed tests"
    sudo -E bash /opt/qa/regression.sh ${TEST_FILES[*]}
else
    sudo -E bash /opt/qa/regression.sh
fi

RET=$?

if [ ${RET} -ne 0 ]; then
    sudo mv /tmp/gluster_regression.txt $WORKSPACE || true
    sudo chown jenkins:jenkins gluster_regression.txt || true
    echo ${BUILD_URL} >> gluster_regression.txt || true
    echo "Logs are archived at Build artifacts: https://build.gluster.org/job/${JOB_NAME}/${BUILD_ID}"
else
    # leave result file empty if there is no failure, in context of `comment-file` in ghprb plugin
    touch gluster_regression.txt
fi
# do clean up after a regression test suite is run
sudo -E bash /opt/qa/cleanup.sh
# make sure that every file/diretory belongs to jenkins
sudo chown -R jenkins:jenkins $WORKSPACE
exit $RET
