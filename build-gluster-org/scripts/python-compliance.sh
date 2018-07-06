#!/usr/bin/bash
grep -rnl '#!/usr/bin/python' | xargs pylint-3 --py3k
find . -name '*.py' | xargs pylint-3 --py3k
find . -name '*.in' | xargs file | grep 'Python' | awk '{print $1}' | cut -d: -f 1 | xargs pylint-3 --py3k
