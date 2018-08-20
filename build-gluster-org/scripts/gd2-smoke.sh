#!/bin/bash

set -e

# build the glusterfs source code
/opt/qa/build.sh

# run gd2 unit tests script
/opt/qa/glusterd2-test.sh
