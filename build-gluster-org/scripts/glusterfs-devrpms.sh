#!/bin/bash
./autogen.sh || exit 1
./configure --enable-gnfs --enable-fusermount || exit 1
cd extras/LinuxRPM
make prep srcrpm || exit 1
sudo mock -r {build_flag} --config-opts=dnf_warning=False --resultdir=${{WORKSPACE}}/RPMS/"%(dist)s"/"%(target_arch)s"/ --with=gnfs --cleanup-after --rebuild glusterfs*src.rpm || exit 1
