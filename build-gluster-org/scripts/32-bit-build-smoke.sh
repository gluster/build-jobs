#!/bin/bash

nproc=$(getconf _NPROCESSORS_ONLN)
sudo mock -r fedora-32-i386 --config-opts=dnf_warning=False --init
sudo mock -r fedora-32-i386 --config-opts=dnf_warning=False --install langpacks-en glibc-langpack-en automake autoconf libtool flex bison openssl-devel libxml2-devel python-devel libaio-devel libibverbs-devel librdmacm-devel readline-devel lvm2-devel glib2-devel userspace-rcu-devel libcmocka-devel libacl-devel sqlite-devel fuse-devel redhat-rpm-config clang clang-analyzer git rpcgen libtirpc-devel libuuid-devel rpcgen 
sudo mock -r fedora-32-i386 --config-opts=dnf_warning=False --copyin $WORKSPACE /src
sudo mock -r fedora-32-i386 --config-opts=dnf_warning=False --chroot "cd /src && ./autogen.sh"
sudo mock -r fedora-32-i386 --config-opts=dnf_warning=False --chroot "cd /src && ./configure --enable-gnfs --enable-debug"
sudo mock -r fedora-32-i386 --config-opts=dnf_warning=False --chroot "cd src && make install CFLAGS='-Wall -Werror -Wno-address-of-packed-member' -j ${nproc}"
ret=$?
sudo mock -r fedora-32-i386 --config-opts=dnf_warning=False --clean
exit $ret
