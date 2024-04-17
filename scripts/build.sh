#!/usr/bin/bash

set -ex

# Clean out folder 
find /opt/output/ -mindepth 1 -maxdepth 1 -exec rm -r -- {} + 

# Setup srcs
cd /opt
mkdir -p src
rsync -azh /opt/orig/tdawson-misc-scripts/ /opt/src/tdawson-misc-scripts/

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
cd /opt/src/tdawson-misc-scripts/willit/

python3 willit.py
bash willit-fix-dates.sh
python3 willit-fix-dates.py

rsync -azh /opt/src/tdawson-misc-scripts/willit/output/ /opt/output/willit/