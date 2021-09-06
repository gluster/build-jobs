#!/bin/bash

RESULT="$WORKSPACE/flake8"
mkdir $RESULT

./autogen.sh
./configure --enable-debug --enable-gnfs --silent

# create and activate virtual env
python3 -m venv env
. env/bin/activate

#install flake8
pip install -I flake8

# run flake8
find . -path './env' -prune -o -name '*.py' -print | xargs flake8 > "$RESULT/flake8-check.txt"
FLAKE_COUNT="$(wc -l < $RESULT/flake8-check.txt)"

#fail build if there's any flake8 related issues
if [ $FLAKE_COUNT -gt 0 ]; then
  echo ""
  echo "========================================================="
  echo "              Result of python linter"
  echo "         Number of flake8 issues: ${FLAKE_COUNT}"
  echo "========================================================="
fi
