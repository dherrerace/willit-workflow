#!/usr/bin/bash

set -e

podman build -t willit-deploy -f ./podman/Containerfile .
