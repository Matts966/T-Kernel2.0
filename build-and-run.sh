#!/bin/bash
set -e
docker build -t qt .
docker run --rm -it --net=host --privilaged qt /bin/sh
