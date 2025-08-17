#!/usr/bin/env bash
set -euo pipefail

# Bootstrap an AirBridge edge worker bound to a named queue.
# Fetches configuration and token from the control plane before
# starting the worker. Optionally exposes a Prometheus metrics endpoint.

usage() {
  cat <<USAGE >&2
Usage: $0 --queue <name> [--metrics-port <port>]
  --queue         Queue name to bind this worker to (required)
  --metrics-port  Port to expose Prometheus metrics on (optional)

Environment variables:
  CONTROL_PLANE_URL  Base URL for the control plane (default: https://localhost:8080)
USAGE
  exit 1
}

queue=""
metrics_port=""

while [ $# -gt 0 ]; do
  case "$1" in
    --queue)
      queue="${2:-}"
      shift 2
      ;;
    --metrics-port)
      metrics_port="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      ;;
  esac
done

[ -n "$queue" ] || usage

CONTROL_PLANE_URL="${CONTROL_PLANE_URL:-https://localhost:8080}"
AIRFLOW_HOME="$(mktemp -d)"
export AIRFLOW_HOME

# Fetch worker configuration and token from control plane
curl -fsSL "${CONTROL_PLANE_URL}/edge_worker/v1/config?queue=${queue}" -o "${AIRFLOW_HOME}/airflow.cfg"
CONTROL_PLANE_TOKEN="$(curl -fsSL "${CONTROL_PLANE_URL}/edge_worker/v1/token?queue=${queue}")"
export CONTROL_PLANE_TOKEN

# Validate queue registration
curl -fsS "${CONTROL_PLANE_URL}/edge_worker/v1/queues/${queue}" >/dev/null
# Validate control plane heartbeat
curl -fsS "${CONTROL_PLANE_URL}/health" >/dev/null

if [ -n "$metrics_port" ]; then
  export AIRFLOW__PROMETHEUS__METRICS_PORT="$metrics_port"
  export AIRFLOW__PROMETHEUS__ENABLED=True
fi

# Start the edge worker; replace shell with worker process
exec airflow edge-worker --queue "$queue"
