#!/usr/bin/env bash
set -euo pipefail

: "${AIRFLOW_HOME:=/opt/airflow}"

# Load secrets from AWS Secrets Manager if secret IDs are provided
if [ -n "${JWT_SECRET_ID:-}" ] || [ -n "${EDGE_API_TOKEN_ID:-}" ]; then
  eval "$(
    python <<'PY'
import os, shlex
try:
    import boto3
except Exception:
    raise SystemExit
client = boto3.client('secretsmanager', region_name=os.getenv('AWS_REGION'))
mapping = {'JWT_SECRET_ID': 'JWT_SECRET', 'EDGE_API_TOKEN_ID': 'EDGE_API_TOKEN'}
for env_id, env_var in mapping.items():
    secret_id = os.getenv(env_id)
    if not secret_id:
        continue
    try:
        value = client.get_secret_value(SecretId=secret_id)['SecretString']
        print(f"export {env_var}={shlex.quote(value)}")
    except Exception:
        pass
PY
  )"
fi

# Initialize database if needed
airflow db migrate

# Execute the container's main process
exec "$@"
