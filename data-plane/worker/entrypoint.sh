#!/bin/sh
set -e

# Inject token from file if provided
if [ -n "${CONTROL_PLANE_TOKEN_FILE:-}" ] && [ -f "${CONTROL_PLANE_TOKEN_FILE}" ]; then
  export CONTROL_PLANE_TOKEN="$(cat "${CONTROL_PLANE_TOKEN_FILE}")"
fi

exec "$@"
