#!/bin/bash

RESULT="$WORKSPACE/pylint"
mkdir $RESULT

./autogen.sh
./configure --enable-debug --enable-gnfs --silent

# create and activate virtual env
python3 -m venv env
. env/bin/activate

#install pylint
pip install -I pylint

#run pylint
find . -path './env' -prune -o -name '*.py' -print | xargs pylint --output-format=text > "$RESULT/pylint-check.txt"
PYLINT_COUNT="$(egrep -wc 'R:|C:|W:|E:|F:' $RESULT/pylint-check.txt)"

#fail build if there's any pylint related issues
if [ $PYLINT_COUNT -gt 0 ]; then
  echo ""
  echo "========================================================="
  echo "              Result of python linter"
  echo "         Number of pylint issues: ${PYLINT_COUNT}"
  echo "========================================================="
fi
