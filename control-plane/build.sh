#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")" && pwd)

docker build -t airbridge-webserver:3.0.4 -f "$ROOT_DIR/webserver/Dockerfile" "$ROOT_DIR"
docker build -t airbridge-scheduler:3.0.4 -f "$ROOT_DIR/scheduler/Dockerfile" "$ROOT_DIR"
docker build -t airbridge-triggerer:3.0.4 -f "$ROOT_DIR/triggerer/Dockerfile" "$ROOT_DIR"
