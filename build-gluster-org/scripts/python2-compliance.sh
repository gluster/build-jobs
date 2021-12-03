#!/usr/bin/bash
set -e
./autogen.sh
./configure --enable-debug --enable-gnfs --silent --disable-linux-io_uring
find . -name '*.py' | xargs python2 /opt/qa/python_compliance.py
