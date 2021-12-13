#!/bin/bash

CHROOT=fedora-35-i386
OPTIONS="-r $CHROOT --config-opts=dnf_warning=False"
MOCK="sudo mock $OPTIONS"
nproc=$(getconf _NPROCESSORS_ONLN)
$MOCK --init
$MOCK --install langpacks-en glibc-langpack-en automake autoconf libtool flex bison openssl-devel libxml2-devel python-devel libaio-devel libibverbs-devel librdmacm-devel readline-devel lvm2-devel glib2-devel userspace-rcu-devel libcmocka-devel libacl-devel sqlite-devel fuse-devel redhat-rpm-config clang clang-analyzer git rpcgen libtirpc-devel libuuid-devel rpcgen liburing-devel gperftools-devel gperftools-libs
$MOCK --copyin $WORKSPACE /src
$MOCK --chroot "cd /src && ./autogen.sh"
$MOCK --chroot "cd /src && ./configure --enable-gnfs --enable-debug"
$MOCK --chroot "cd /src && make install CFLAGS='-Wall -Werror' -j ${nproc}"
ret=$?
$MOCK --clean
exit $ret
