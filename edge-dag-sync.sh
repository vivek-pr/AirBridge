#!/usr/bin/env bash
set -euo pipefail

: "${DAG_BUCKET:?DAG_BUCKET must be set}"
DAGS_FOLDER="${DAGS_FOLDER:-/opt/airflow/dags}"
DAG_PREFIX="${DAG_PREFIX:-}"
INTERVAL_SECONDS="${INTERVAL_SECONDS:-60}"
RETRIES="${RETRIES:-5}"

n=0
while true; do
  if aws s3 sync --checksum --delete "s3://${DAG_BUCKET}${DAG_PREFIX:+/${DAG_PREFIX}}" "$DAGS_FOLDER"; then
    n=0
    sleep "$INTERVAL_SECONDS"
  else
    n=$((n+1))
    sleep $((2**n))
    if [ "$n" -ge "$RETRIES" ]; then
      echo "DAG sync failed after $RETRIES attempts" >&2
      exit 1
    fi
  fi
done
