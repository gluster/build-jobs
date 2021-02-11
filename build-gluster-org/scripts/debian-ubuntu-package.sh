#!/bin/bash

#for both the debian and ubuntu packaging of various versions we have to
#ssh to a particular ubuntu machine and package it using pbuilder.

set -xe

deb_flavors=(stretch buster bullseye)
ub_flavors=(bionic groovy xenial focal hirsute)

while [ $# -eq 5 ]
do
        echo "building everything"
        echo "packing debian distribution"
        for i in ${!deb_flavors[@]}; do
        ~/build-gluster-org/scripts/generic_package.sh debian ${deb_flavors[$i]} $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        done

        echo "packing ubuntu distribution"
        for i in ${!ub_flavors[@]}; do
        ~/build-gluster-org/scripts/generic_package.sh debian ${ub_flavors[$i]} $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        done
done

while [ $# -gt 5 ]
do
    if [ "$OS" == "all" ]; then
        echo "packing all distribution"
        echo "packing debian distribution"
        flavors=(stretch buster bullseye)
        for i in ${!deb_flavors[@]}; do
        ~/build-gluster-org/scripts/generic_package.sh debian ${deb_flavors[$i]} $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        done

        echo "packing ubuntu distribution"
        flavors=(bionic groovy xenial focal hirsute)
        for i in ${!ub_flavors[@]}; do
        ~/build-gluster-org/scripts/generic_package.sh debian ${ub_flavors[$i]} $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        done

    elif [ "$OS" == "debian" ]; then
        echo "packing debian alone"
        case $FLAVOR in
        "stretch" | "9" | "buster" | "10" | "bullseye" | "11")
        echo "packing debian ${FLAVOR} alone"
        ../scripts/generic_package.sh $OS $FLAVOR $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        ;;
        esac

    elif [ "$OS" == "ubuntu" ]; then
        echo "packing ubuntu alone"
        case $FLAVOR in
        "xenial" | "16.04" | "bionic" | "18.04" | "eoan" | "19.10" | "focal" | "Focal Fossa" | "20.04" | "hirsute" | "21.04" | "hirsute hippo")
        echo "packing ubuntu ${FLAVOR} alone"
        ../scripts/generic_package.sh $OS $FLAVOR $SERIES $VERSION $RELEASE $LATEST_SERIES $LATEST_VERSION
        ;;
        esac
    fi
done

RET=$?

exit $RET
