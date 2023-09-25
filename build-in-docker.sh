#!/bin/bash
if [ ! -d "target" ]; then
  mkdir "target"
fi
docker build -t nexus-builder .
docker run -v "$(pwd):/app/buildDir" nexus-builder
