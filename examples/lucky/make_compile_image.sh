#!/bin/sh

export CRYSTAL_VERSION="0.23.1"

docker build -t crystal/build-img:$CRYSTAL_VERSION -f config/deploy/Dockerfile.dreamhost .
