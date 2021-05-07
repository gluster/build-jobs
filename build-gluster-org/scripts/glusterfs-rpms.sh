#!/bin/bash
./autogen.sh || exit 1
./configure --enable-fusermount --disable-linux-io_uring || exit 1
cd extras/LinuxRPM
make prep srcrpm || exit 1
sudo mock -r {build_flag}  --config-opts=dnf_warning=False --resultdir=${{WORKSPACE}}/RPMS/"%(dist)s"/"%(target_arch)s"/ --with=gnfs --rebuild glusterfs*src.rpm || exit 1
