#!/bin/sh

pkill mock || true
SLEEP=0
while [ $SLEEP -lt 30 ]
do
    echo "Waiting for mock to exit cleanly. Attempt #: $SLEEP"
    sleep 1
    pgrep -x mock
    if [ $? -eq 1 ]
    then
        exit 0
    fi
    SLEEP=$((SLEEP+1))
done
echo "Force-killing mock"
pkill -9 mock
