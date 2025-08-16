# Control Plane Configuration

The control plane ships with an Airflow configuration tailored for edge execution.
Key settings include:

- `[core] executor = EdgeExecutor`
- Edge API enabled so edge workers can communicate with the control plane.
- Token based authentication for the Edge API; tokens are supplied via environment variables.

## Enabling the Edge API

1. Create a Kubernetes secret containing the token:
   ```bash
   kubectl create secret generic edge-api-token --from-literal=token=<token>
   ```
2. Set `.Values.edgeApi.enabled` to `true` and provide the secret name via
   `.Values.edgeApi.tokenSecretName` in the Helm chart values.
3. The webserver deployment reads the token from the secret and exposes it to
   Airflow via the `EDGE_API_TOKEN` environment variable.

With these settings the scheduler runs using the `EdgeExecutor` and the webserver
exposes the authenticated Edge API.
