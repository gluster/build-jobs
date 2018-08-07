#!/bin/bash

# Remove any gluster daemon leftovers from aborted runs
sudo -E bash /opt/qa/cleanup.sh

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

#compile the code with coverage options
set -e
./autogen.sh || exit 1
P=/build
./configure {,GF_FUSE_,GF_GLUSTERFS_,GF_}CFLAGS="-g3 -O0 -lgcov --coverage -fprofile-arcs -ftest-coverage" --prefix=$P/install --with-mountutildir=$P/install/sbin --with-initdir=$P/install/etc --localstatedir=/var  --enable-debug --enable-gnfs --silent  || exit 1
make install

echo "Initializing the line coverage"
mkdir coverage
lcov -d . --zerocounters
lcov -i -c -d . -o coverage/glusterfs-lcov.info
set +e

echo "Running the regression test"
sudo -E bash /opt/qa/regression.sh -c -t 300
mv glusterfs-logs.tgz regression-glusterfs-logs.tgz
REGRESSION_STATUS=$?

echo "Running the smoke tests"
sudo -E bash /opt/qa/smoke.sh -c
mv glusterfs-logs.tgz smoke-glusterfs-logs.tgz
SMOKE_STATUS=$?

echo "Capturing the line coverage in the .info file"
lcov -c -d . -o coverage/glusterfs-lcov.info
sed -i.bak '/stdout/d' coverage/glusterfs-lcov.info

#Generating the html page for code coverage details using genhtml
genhtml -o coverage/ coverage/glusterfs-lcov.info
echo "The HTML report is generated as index.html file"

if [ $REGRESSION_STATUS -ne 0 ] || [ $SMOKE_STATUS -ne 0 ];
    then
    echo "Smoke test or regression tests failed"
    exit 1
fi
