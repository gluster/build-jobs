#!/bin/sh
set -e
virtualenv --system-site-packages env
env/bin/pip install tox
env/bin/tox
