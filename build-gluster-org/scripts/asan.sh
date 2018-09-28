#!/bin/bash
nproc=$(getconf _NPROCESSORS_ONLN)
SRC=$(pwd);
P=/build;

sudo -E bash /opt/qa/cleanup.sh
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

# Temporarily revert the libtool linking flags for the ASAN jobs. This does not
# work with ASAN

set -e
./autogen.sh;
rm -rf $P/scratch;
mkdir -p $P/scratch;
cd $P/scratch;
rm -rf $P/install;
$SRC/configure --prefix=$P/install --with-mountutildir=$P/install/sbin \
               --with-initdir=$P/install/etc --localstatedir=/var \
               --enable-debug --enable-gnfs --silent --enable-asan
make install -j ${nproc}
cd $SRC;
export ASAN_OPTIONS=log_path=/var/log/glusterfs/asan-output.log
sudo -E bash /opt/qa/regression.sh -c
