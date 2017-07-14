#!/bin/bash
./autogen.sh
./configure
RESULT="$WORKSPACE/results"
mkdir $RESULT
cppcheck --enable=all --inconclusive --xml --xml-version=2 . 2>"$RESULT/cppcheck.xml" 


