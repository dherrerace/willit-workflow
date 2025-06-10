#!/usr/bin/bash

set -ex

# Clean out folder 
find /opt/output/ -mindepth 1 -maxdepth 1 -exec rm -r -- {} + 

# Setup srcs
cd /opt
mkdir -p src
rsync -azh /opt/orig/willit/ /opt/src/willit/

# Apply patches
if [ -d "./patches" ]; then
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

if ! test -f willit-config.json
then
    echo === Prepare to merge ===
    mkdir output

    # Get all specific repo webpages
    cp -r $(find . -mindepth 2 -maxdepth 2 -type d -iwholename "./output-*") output/

    # Merge all status-overall.json files into one
    jq \
        -s add \
        $( \
            echo $( \
                find . \
                    -mindepth 2 -maxdepth 2 \
                    -type f \
                    -iwholename "./output-*/status-overall.json" \
            ) \
        ) > output/status-overall.json

    # Generate landing page
    echo '{ "repos": [] }' > willit-config.json

fi

python3 willit.py

rsync -azh /opt/src/willit/output/ /opt/output/