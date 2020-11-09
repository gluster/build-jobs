#!/bin/sh

sudo pkill mock || true
SLEEP=0
while [ $SLEEP -lt 60 ]
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
sudo pkill -9 mock
mount | grep /var/lib/mount/
if [$? -eq 1 ]
then
    # {{is doubled to be escaped for jjb
    umount $(mount | grep /var/lib/mock/ | awk '{{print $3}}')
fi    
