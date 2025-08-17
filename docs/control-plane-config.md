# Control Plane Configuration

The control plane ships with an Airflow configuration tailored for edge execution.
Key settings include:

- `[core] executor = edge_executor.EdgeExecutor`
- Edge API enabled so edge workers can communicate with the control plane.
- Token based authentication for the Edge API; tokens are supplied via environment variables.
- Remote task logs written to S3 under `s3://<project>-logs/logs` with local logs deleted after upload.
- Requires the `apache-airflow-providers-amazon` package for S3 logging support.

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

## Ingress and TLS

The control-plane UI and API can be exposed through a Kubernetes Ingress. Enable
it by setting `.Values.ingress.enabled` and providing the desired `controller`
(`nginx` or `gke`) and `host` in your values file. TLS certificates may be
referenced via a secret, ACM ARN, or cert-manager issuer using the
`ingress.tls` block.

Optional security features include IP allow lists, basic rate limiting and WAF
integration. For NGINX, supply ranges in `ingress.ipAllowList` and set
`ingress.waf.enabled` to activate ModSecurity. On GKE, a Cloud Armor policy name
can be provided in `ingress.waf.securityPolicy`.

Expose a health check endpoint with `ingress.healthCheckPath` and ensure your
monitoring system tracks 4xx and 5xx response rates for early detection of
problems.
