#!/bin/bash
set -e
docker build -t qt .
docker run --rm -it --network=host --privileged qt /bin/sh
