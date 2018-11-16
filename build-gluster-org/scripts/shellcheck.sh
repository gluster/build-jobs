#!/bin/bash

./autogen.sh
./configure --disable-bd-xlator --enable-debug --enable-gnfs --silent

find . -path ./.git -prune -o -path ./tests -prune -o -exec file {} \; \
  | grep "shell script" \
  | cut -d: -f 1 \
  | xargs shellcheck \
  >shellcheck.txt

SHELLCHECK_COUNT="$(grep -c 'In' shellcheck.txt)"

#fail build if there's any issue or warning
if [[ "$SHELLCHECK_COUNT" -gt 0 ]]; then
  echo ""
  echo "========================================================="
  echo "              Result of ShellCheck"
  echo "         Number of ShellCheck errors/warnings: ${SHELLCHECK_COUNT}"
  echo "========================================================="
  exit 1
fi
