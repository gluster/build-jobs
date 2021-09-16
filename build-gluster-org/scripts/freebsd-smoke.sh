#!/usr/local/bin/bash

/opt/qa/build.sh
RET=$?
echo $RET
if [ $RET -ne 0 ]; then
    exit 1
fi

#sudo /opt/qa/smoke.sh
#RET=$?
#echo smoke.sh returned $RET
exit $RET
