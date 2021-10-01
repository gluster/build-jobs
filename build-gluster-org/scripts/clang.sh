#!/bin/bash
MOCK="sudo mock -r $MOCK_CHROOT --config-opts=dnf_warning=False"

$MOCK --init
$MOCK --install rpcgen libtirpc-devel langpacks-en glibc-langpack-en automake autoconf libtool flex bison openssl-devel libxml2-devel python-devel libaio-devel libibverbs-devel librdmacm-devel readline-devel lvm2-devel glib2-devel userspace-rcu-devel libcmocka-devel libacl-devel sqlite-devel fuse-devel libuuid-devel redhat-rpm-config clang clang-analyzer git gperftools-devel
$MOCK --copyin $WORKSPACE /src
$MOCK --chroot "cd /src && ./autogen.sh"
$MOCK --chroot "cd /src && ./configure CC=clang --enable-gnfs --enable-debug --disable-linux-io_uring"
$MOCK --chroot "cd /src && scan-build -o /src/clangScanBuildReports -disable-checker deadcode.DeadStores -v -v --use-cc clang --use-analyzer=/usr/bin/clang make"
$MOCK --copyout /src/clangScanBuildReports $WORKSPACE/clangScanBuildReports
$MOCK --clean
sudo chown -R jenkins:jenkins clangScanBuildReports
