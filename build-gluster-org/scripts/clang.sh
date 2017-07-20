./autogen.sh
./configure CC=clang
scan-build -o ${WORKSPACE}/clangScanBuildReports -v -v --use-cc clang --use-analyzer=/usr/bin/clang make
