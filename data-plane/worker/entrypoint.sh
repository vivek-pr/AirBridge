#!/bin/sh
set -e

# Inject token from file if provided
if [ -n "${CONTROL_PLANE_TOKEN_FILE:-}" ] && [ -f "${CONTROL_PLANE_TOKEN_FILE}" ]; then
  export CONTROL_PLANE_TOKEN="$(cat "${CONTROL_PLANE_TOKEN_FILE}")"
fi

# Fetch token from AWS Secrets Manager if an ID is provided
if [ -n "${CONTROL_PLANE_TOKEN_ID:-}" ]; then
  CONTROL_PLANE_TOKEN="$(python - <<'PY'
import os
try:
    import boto3
except Exception:
    raise SystemExit
client = boto3.client('secretsmanager', region_name=os.getenv('AWS_REGION'))
print(client.get_secret_value(SecretId=os.environ['CONTROL_PLANE_TOKEN_ID'])['SecretString'])
PY
  )" && export CONTROL_PLANE_TOKEN
fi

exec "$@"
