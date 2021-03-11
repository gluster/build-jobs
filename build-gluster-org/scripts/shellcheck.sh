#!/bin/bash
set -e
set -o pipefail
./autogen.sh
./configure --enable-debug --enable-gnfs --silent

find . -path ./.git -prune -o -path ./tests -prune -o -exec file {} \; \
  | grep "shell script" \
  | cut -d: -f 1 \
  | grep -v '^./configure$' \
  | grep -v '^./ltmain.sh$' \
  | grep -v '^./libtool$' \
  | grep -v '^./config.status$' \
  | grep -v '^./config.guess$' \
  | grep -v '^./install-sh$' \
  | grep -v '^./depcomp$' \
  | grep -v '^./compile$' \
  | grep -v '^./config.sub$' \
  | grep -v '^./test-driver$' \
  | grep -v '^./build-aux/pkg-version$' \
  | grep -v '^./autogen.sh$' \
  | grep -v '^./missing$' \
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
