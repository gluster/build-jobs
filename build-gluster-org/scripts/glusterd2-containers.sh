#!/bin/bash
IMG_NAME="gluster/glusterd2-nightly"
IMG_VERSION=$(date +%Y%m%d)

cd extras/nightly-container
./build.sh
if [ "$PUSH_TO_HUB" = true ]; then
    buildah push --authfile $AUTH_JSON "localhost/$IMG_NAME:$IMG_VERSION" "docker://docker.io/gluster/glusterd2-nightly:$IMG_VERSION"
    buildah push --authfile $AUTH_JSON "localhost/$IMG_NAME:$IMG_VERSION" "docker://docker.io/gluster/glusterd2-nightly:latest"
fi
buildah rmi --all || true
