#!/bin/sh
set -e
source /opt/rh/python27/enable
virtualenv --system-site-packages env
env/bin/pip install flake8
env/bin/flake8
