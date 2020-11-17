#!/bin/bash

#for both the debian and ubuntu packaging of various versions we have to
#ssh to a particular ubuntu machine and package it using pbuilder.

set -xe

while [ $# -eq 5 ]
do
        echo "building everything"
        echo "packing debian distribution"
        ~/build-gluster-org/scripts/generic_package.sh debian stretch $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        ~/build-gluster-org/scripts/generic_package.sh debian buster $SERIES $VERSION $RELEASE
        ~/build-gluster-org/scripts/generic_package.sh debian bullseye $SERIES $VERSION $RELEASE
        echo "packing ubuntu distribution"
        ~/build-gluster-org/scripts/generic_package.sh ubuntu xenial $SERIES $VERSION $RELEASE
        ~/build-gluster-org/scripts/generic_package.sh ubuntu bionic $SERIES $VERSION $RELEASE
        ~/build-gluster-org/scripts/generic_package.sh ubuntu disco $SERIES $VERSION $RELEASE
        ~/build-gluster-org/scripts/generic_package.sh ubuntu eoan $SERIES $VERSION $RELEASE
        ~/build-gluster-org/scripts/generic_package.sh ubuntu focal $SERIES $VERSION $RELEASE
done

while [ $# -gt 5 ]
do
    if [ "$OS" == "all" ]; then
        echo "packing all distribution"
        echo "packing debian distribution"
        ~/build-gluster-org/scripts/generic_package.sh debian stretch $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        ~/build-gluster-org/scripts/generic_package.sh debian buster $SERIES $VERSION $RELEASE
        ~/build-gluster-org/scripts/generic_package.sh debian bullseye $SERIES $VERSION $RELEASE
        echo "packing ubuntu distribution"
        ~/build-gluster-org/scripts/generic_package.sh ubuntu xenial $SERIES $VERSION $RELEASE
        ~/build-gluster-org/scripts/generic_package.sh ubuntu bionic $SERIES $VERSION $RELEASE
        ~/build-gluster-org/scripts/generic_package.sh ubuntu disco $SERIES $VERSION $RELEASE
        ~/build-gluster-org/scripts/generic_package.sh ubuntu eoan $SERIES $VERSION $RELEASE
        ~/build-gluster-org/scripts/generic_package.sh ubuntu focal $SERIES $VERSION $RELEASE
    elif [ "$OS" == "debian" ]; then
        echo "packing debian alone"
        if [ "$FLAVOR" == "stretch" ] || [ "$FLAVOR" == "9" ]; then
        echo "packing debian stretch alone"
        ../scripts/generic_package.sh $OS $FLAVOR $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        fi
        if [ "$FLAVOR" == "buster" ] || [ "$FLAVOR" == "10" ]; then
        echo "packing debian buster alone"
        ../scripts/generic_package.sh $OS $FLAVOR $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        fi
        if [ "$FLAVOR" == "bullseye" ] || [ "$FLAVOR" == "11" ]; then
        echo "packing debian bullseye alone"
        ../scripts//generic_package.sh $OS $FLAVOR $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        fi
    elif [ "$OS" == "ubuntu" ]; then
        echo "packing ubuntu alone"
        if [ "$FLAVOR" == "xenial" ] || [ "$FLAVOR" == "16.04" ]; then
        echo "packing xenial alone"
        ../scripts/generic_package.sh $OS $FLAVOR $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        fi
        if [ "$FLAVOR" == "bionic" ] || [ "$FLAVOR" == "18.04" ]; then
        echo "packing bionic alone"
        ../scripts/generic_package.sh $OS $FLAVOR $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        fi
        if [ "$FLAVOR" == "disco" ] || [ "$FLAVOR" == "19.04" ]; then
        echo "packing disco alone"
        ../scripts/generic_package.sh $OS $FLAVOR $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        fi
        if [ "$FLAVOR" == "eoan" ] || [ "$FLAVOR" == "19.10" ]; then
        echo "packing eoan alone"
        ../scripts/generic_package.sh $OS $FLAVOR $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        fi
        if [ "$FLAVOR" == "focal" ] || [ "$FLAVOR" == "20.04" ] || [ "$FLAVOR" == "focal fossa"]; then
        echo "packing focal alone"
        ../scripts/generic_package.sh $OS $FLAVOR $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        fi
        if [ "$FLAVOR" == "hirsute" ] || [ "$FLAVOR" == "21.04" ] || [ "$FLAVOR" == "hirsute hippo"]; then
    fi
done

RET=$?

exit $RET
