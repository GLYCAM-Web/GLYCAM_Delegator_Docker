#!/usr/bin/env bash

### Remove all conda-related code installed after image generation
##  This removes conda and the ambertools installation
# Mounted to /programs
rm -rf deps/conda
# Inside the container user's homedir
( cd mounts/containerUser/ && rm -rf .bashrc .cache/ .conda/ .local/ )

