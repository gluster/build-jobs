#!/bin/bash

RESULT="$WORKSPACE/python-lint"
mkdir $RESULT

./autogen.sh
./configure --disable-bd-xlator --enable-debug --enable-gnfs --silent

# create and activate virtual env
python3 -m venv env
. env/bin/activate

#install flake8 and pylint
pip install -I flake8 pylint

# run flake8
flake8 . >"$RESULT/flake8-check.txt"
FLAKE_COUNT="$(wc -l < '$RESULT/flake8-check.txt')"

#run pylint
find . -iname "*.py" | xargs pylint --output-format=text >"$RESULT/pylint-check.txt"
PYLINT_COUNT="$(egrep -wc 'R:|C:|W:|E:|F:' pylint-check.txt)"

#fail build if there's any pylint and flake8 related issues
if [[ "$FLAKE_COUNT" -gt 0  && "$PYLINT_COUNT" -gt 0 ]]; then
  echo ""
  echo "========================================================="
  echo "              Result of python linter"
  echo "         Number of flake8 issues: ${FLAKE_COUNT}"
  echo "         Number of pylint issues: ${PYLINT_COUNT}"
  echo "========================================================="
  exit 1
fi
