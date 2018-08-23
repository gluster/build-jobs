#!/bin/bash

set -e

SRC=$(pwd);
nproc=$(getconf _NPROCESSORS_ONLN)

./autogen.sh;
P=/build;
rm -rf $P/scratch;
mkdir -p $P/scratch;
cd $P/scratch;
rm -rf $P/install;
$SRC/configure --prefix=$P/install --with-mountutildir=$P/install/sbin \
               --with-initdir=$P/install/etc --localstatedir=/var \
               --disable-bd-xlator --enable-debug --enable-gnfs --silent
make CFLAGS="-Wall -Werror -Wno-cpp" -j ${nproc};
