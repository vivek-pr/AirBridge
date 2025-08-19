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


export AIRFLOW__CORE__EXECUTOR=airflow.providers.edge3.executors.EdgeExecutor
export AIRFLOW__EDGE__API_ENABLED=True
export AIRFLOW__EDGE__API_URL=http://localhost:8080/edge_worker/v1/rpcapi
export AIRFLOW__API_AUTH__JWT_SECRET=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJlZGdlLXdvcmtlciIsImlhdCI6MTc1NTYzNTExNywibmJmIjoxNzU1NjM1MTEyLCJleHAiOjE3NTU2Mzg3MTcsImF1ZCI6InVybjphaXJmbG93LmFwYWNoZS5vcmc6dGFzayJ9.X4wUOu26SxckgkmmnytT_BYzYUernXmKw6Vy-cfkTak
export EDGE_API_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJlZGdlLXdvcmtlciIsImlhdCI6MTc1NTYzNTExNywibmJmIjoxNzU1NjM1MTEyLCJleHAiOjE3NTU2Mzg3MTcsImF1ZCI6InVybjphaXJmbG93LmFwYWNoZS5vcmc6dGFzayJ9.X4wUOu26SxckgkmmnytT_BYzYUernXmKw6Vy-cfkTak


exec "$@"
