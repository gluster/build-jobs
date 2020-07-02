#!/bin/bash

./autogen.sh
./configure --enable-gnfs --enable-debug --silent
nproc=$(getconf _NPROCESSORS_ONLN)

# This is a hack to get Coverity to work with GCC8, all of them may not be
# needed in EL7 at the moment, but if someone wants to do this on Fedora, these
# are the steps
cat <<EOF >> site.h
#ifndef __COVERITY_GCC_VERSION_AT_LEAST
    #define __COVERITY_GCC_VERSION_AT_LEAST(x, y) 0
    #define FAKE__COVERITY_GCC_VERSION_AT_LEAST__
#endif /* __COVERITY_GCC_VERSION_AT_LEAST */
#ifdef __x86_64__
    #if __COVERITY_GCC_VERSION_AT_LEAST(7, 0)
        typedef float _Float128 __attribute__((__vector_size__(128)));
        typedef float _Float32 __attribute__((__vector_size__(32)));
        typedef float _Float32x __attribute__((__vector_size__(32)));
        typedef float _Float64 __attribute__((__vector_size__(64)));
        typedef float _Float64x __attribute__((__vector_size__(64)));
    #endif
#endif
EOF
/opt/cov-analysis-linux64-2019.03/bin/cov-build --dir cov-int make -j ${nproc};
tar czvf glusterfs.tgz cov-int
BUILD_DATE=$(date "+%Y-%m-%d")
BUILD_VERSION=$(git log -n1 --pretty='%h')
curl --form token="${COVERITY_TOKEN}" \
  --form email="${COVERITY_EMAIL}" \
  --form file=@glusterfs.tgz \
  --form version="${BUILD_DATE}-${BUILD_VERSION}" \
  --form description="Nightly build on ${BUILD_DATE}" \
  https://scan.coverity.com/builds?project=gluster%2Fglusterfs
