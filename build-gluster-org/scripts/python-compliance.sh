#!/usr/bin/bash
./autogen.sh
./configure --disable-bd-xlator --enable-debug --enable-gnfs --silent
grep -rnl '#!/usr/bin/python' | xargs pylint-3 --py3k
find . -name '*.py' | xargs pylint-3 --py3k
find . -name '*.py' | xargs python2 /opt/qa/python_compliance.py
find . -name '*.py' | xargs python3 /opt/qa/python_compliance.py
