#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")" && pwd)

# Build current images (Airflow 3.0.6 per Dockerfiles) and add 3.0.4 compatibility tags
docker build -t airbridge-webserver:3.0.6 -f "$ROOT_DIR/webserver/Dockerfile" "$ROOT_DIR"
docker tag airbridge-webserver:3.0.6 airbridge-webserver:3.0.4 || true

docker build -t airbridge-scheduler:3.0.6 -f "$ROOT_DIR/scheduler/Dockerfile" "$ROOT_DIR"
docker tag airbridge-scheduler:3.0.6 airbridge-scheduler:3.0.4 || true

docker build -t airbridge-triggerer:3.0.6 -f "$ROOT_DIR/triggerer/Dockerfile" "$ROOT_DIR"
docker tag airbridge-triggerer:3.0.6 airbridge-triggerer:3.0.4 || true
