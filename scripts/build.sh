#!/usr/bin/bash

set -ex

# Clean out folder 
find /opt/output/ -mindepth 1 -maxdepth 1 -exec rm -r -- {} + 

# Setup srcs
cd /opt
mkdir -p src
rsync -azh /opt/orig/willit/ /opt/src/willit/

# Apply patches
if [ ! -z "./patches" ]; then
    pushd patches
    if [ ! -z "$(ls -A */ 2> /dev/null)" ]; then
        for d in */ ; do
            for p in ${d}*.patch; do
                echo "patch /opt/patches/$p"
                (cd /opt/src/${d}; patch -p1 < /opt/patches/$p)
            done
        done
    fi
    popd
fi

# Build
cd /opt/src/willit/

python3 willit.py

rsync -azh /opt/src/willit/output/ /opt/output/willit/