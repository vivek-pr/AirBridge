#!/usr/bin/env bash
set -euo pipefail

: "${AIRFLOW_HOME:=/opt/airflow}"

# Initialize database if needed
airflow db migrate

# Execute the container's main process
exec "$@"
