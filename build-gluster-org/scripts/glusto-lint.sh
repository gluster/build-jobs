#!/bin/sh
set -e
virtualenv --system-site-packages env
# see https://bugzilla.redhat.com/show_bug.cgi?id=1683650
env/bin/pip install --upgrade pip
env/bin/pip install tox
env/bin/tox

# Commit message standard
if ! git show --pretty=format:%B | head -n 2 | tail -n 1 | egrep '^$' >/dev/null 2>&1 ; then
    echo "Bad commit message format! Please add an empty line after the subject line. Do not break subject line with new-lines."
    exit 1
fi

# verify that every folder has an __init__.py file
set +e
FOLDERLIST=$(find tests/functional -type d -print0 | xargs -0 -I {} ls {}/__init__.py)
RET=$?
set -e
if [ $RET -ne 0 ]; then
    echo "One of the folders in this change does not have an __init__.py file"
    exit 1
fi
