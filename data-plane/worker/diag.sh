#!/bin/sh
set -e

if [ -z "${CONTROL_PLANE_URL:-}" ]; then
  echo "CONTROL_PLANE_URL not set" >&2
  exit 1
fi

curl -sv -H "Authorization: Bearer ${CONTROL_PLANE_TOKEN:-}" "${CONTROL_PLANE_URL}/health"
