#!/bin/bash

RESULT="$WORKSPACE/python-lint"
mkdir $RESULT

./autogen.sh
./configure --enable-debug --enable-gnfs --silent

# run flake8
find . -name '*.py' -print | xargs flake8 > "$RESULT/flake8-check.txt"
FLAKE_COUNT="$(wc -l < $RESULT/flake8-check.txt)"

#run pylint
find . -name '*.py' -print | xargs pylint-3 --output-format=text > "$RESULT/pylint-check.txt"
PYLINT_COUNT="$(egrep -wc 'R:|C:|W:|E:|F:' $RESULT/pylint-check.txt)"

#fail build if there's any pylint and flake8 related issues
if [[ "$FLAKE_COUNT" -gt 0  || "$PYLINT_COUNT" -gt 0 ]]; then
  echo ""
  echo "========================================================="
  echo "              Result of python linter"
  echo "         Number of flake8 issues: ${FLAKE_COUNT}"
  echo "         Number of pylint issues: ${PYLINT_COUNT}"
  echo "========================================================="
  exit 1
fi
