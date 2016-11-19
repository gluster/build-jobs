#!/bin/sh
set -e
source /opt/rh/python27/enable
virtualenv --system-site-packages env
env/bin/pip install tox
env/bin/tox jjb
