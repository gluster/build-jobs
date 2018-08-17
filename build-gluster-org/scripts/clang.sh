#!/bin/bash
sudo mock -r fedora-27-x86_64 --config-opts=dnf_warning=False --init
sudo mock -r fedora-27-x86_64 --config-opts=dnf_warning=False --install langpacks-en glibc-langpack-en automake autoconf libtool flex bison openssl-devel libxml2-devel python-devel libaio-devel libibverbs-devel librdmacm-devel readline-devel lvm2-devel glib2-devel userspace-rcu-devel libcmocka-devel libacl-devel sqlite-devel fuse-devel redhat-rpm-config clang clang-analyzer git
sudo mock -r fedora-27-x86_64 --config-opts=dnf_warning=False --copyin $WORKSPACE /src
sudo mock -r fedora-27-x86_64 --config-opts=dnf_warning=False --chroot "cd /src && ./autogen.sh"
sudo mock -r fedora-27-x86_64 --config-opts=dnf_warning=False --chroot "cd /src && ./configure CC=clang --enable-gnfs --disable-bd --enable-debug"
sudo mock -r fedora-27-x86_64 --config-opts=dnf_warning=False --chroot "cd /src && scan-build -o /src/clangScanBuildReports -disable-checker deadcode.DeadStores -v -v --use-cc clang --use-analyzer=/usr/bin/clang make"
sudo mock -r fedora-27-x86_64 --config-opts=dnf_warning=False --copyout /src/clangScanBuildReports $WORKSPACE/clangScanBuildReports
sudo mock -r fedora-27-x86_64 --config-opts=dnf_warning=False --clean
sudo chown -R jenkins:jenkins clangScanBuildReports
