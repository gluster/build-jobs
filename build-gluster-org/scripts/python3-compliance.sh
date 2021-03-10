#!/usr/bin/bash
set -e
./autogen.sh
./configure --enable-debug --enable-gnfs --silent
grep -rnl --exclude-dir='.git' '#!/usr/bin/python' | xargs pylint-3 --py3k
find . -name '*.py' | xargs pylint-3 --py3k
find . -name '*.py' | xargs python3 /opt/qa/python_compliance.py
