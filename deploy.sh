#!/usr/bin/bash

set -e

mkdir -p $(pwd)/output
mkdir -p $(pwd)/patches

if [ "$EUID" -ne 0 ]; then
    podman unshare chown $UID:$UID -R $(pwd)/output
fi

podman run -ti --rm \
    -v $(pwd)/output:/opt/output/:Z \
    -v $(pwd)/patches:/opt/patches/:ro,Z \
    -v $(pwd)/scripts/:/opt/scripts/:ro,Z \
    -v $(pwd)/.git:/opt/.git/:ro,Z \
    -v $(pwd)/src/tdawson-misc-scripts:/opt/orig/tdawson-misc-scripts/:ro,Z \
    -w /opt \
    willit-deploy:latest \
    bash /opt/scripts/build.sh || true

if [ "$EUID" -ne 0 ]; then
    podman unshare chown 0:0 -R $(pwd)/output
fi