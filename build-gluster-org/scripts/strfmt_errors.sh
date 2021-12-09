#!/bin/bash
./autogen.sh || exit 1
./configure --enable-fusermount || exit 1
cd extras/LinuxRPM
make prep srcrpm || exit 1
sudo mock -r 'fedora-35-i386' --resultdir=${WORKSPACE}/RPMS/"%(dist)s"/"%(target_arch)s"/ --with=tcmalloc --cleanup-after --rebuild glusterfs*src.rpm || exit 1
set -x
sudo chown -R jenkins:jenkins $WORKSPACE

rm -f warnings.txt
grep -E ".*: warning: format '%.*' expects( argument of)? type '.*', but argument .* has type 'ssize_t" ${WORKSPACE}/RPMS/fc35/i686/build.log | tee -a warnings.txt
grep -E ".+: warning: format '%.+' expects( argument of)? type '.+', but argument .+ has type 'size_t" ${WORKSPACE}/RPMS/fc35/i686/build.log | tee -a warnings.txt

cat warnings.txt

WARNINGS=$(wc -l < warnings.txt)
if [ "$WARNINGS" -gt "0" ];
then
    exit 1
fi
