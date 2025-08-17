# Edge Worker Troubleshooting

Common issues and diagnostic steps when bootstrapping an edge worker.

## Cannot reach control plane
- Ensure `CONTROL_PLANE_URL` is correct and accessible.
- Test connectivity:
  ```bash
  curl -f "$CONTROL_PLANE_URL/health"
  ```

## Queue not found
- Verify the queue name passed via `--queue` exists in the control plane.
- List queues:
  ```bash
  curl -f "$CONTROL_PLANE_URL/edge_worker/v1/queues"
  ```

## Authentication failures
- Confirm the token was issued correctly:
  ```bash
  curl -f "$CONTROL_PLANE_URL/edge_worker/v1/token?queue=<queue>"
  ```
- Export the token as `CONTROL_PLANE_TOKEN` before starting the worker.

## Metrics endpoint not responding
- Ensure `--metrics-port` was provided when running `bootstrap-edge.sh`.
- Check the port is open:
  ```bash
  curl -f "http://localhost:<port>/metrics"
  ```
