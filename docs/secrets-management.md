# Secrets Management

This project stores tokens, Airflow connections, and configuration values in AWS Secrets Manager. The Airflow images fetch secrets at startup using the secret identifiers provided through environment variables.

## Storing secrets

1. Create secrets in AWS Secrets Manager. Recommended names:
   - `airflow/connections/<name>` for Airflow connections.
   - `airflow/config/api_auth__jwt_secret` for the webserver JWT secret.
   - `edge-api-token` for the edge API token.
2. Grant the control-plane and edge worker IAM roles permission to `secretsmanager:GetSecretValue`.
3. Provide the secret IDs to pods:
   - set `edgeApi.tokenSecretId` in the Helm chart values.
   - optionally set `controlPlane.tokenSecretId` for edge workers.
   - define `JWT_SECRET_ID` in the control-plane environment.

At container startup, `entrypoint.sh` retrieves each secret and exports the expected environment variables (`EDGE_API_TOKEN`, `CONTROL_PLANE_TOKEN`, `JWT_SECRET`).

## Rotation

Use AWS Secrets Manager rotation to replace tokens on a fixed schedule. For static tokens, rotate at least every 90 days. To verify rotation:

1. Update the secret value in AWS Secrets Manager.
2. Restart the affected pods.
3. Confirm they reload the new secret and continue functioning.

Avoid committing plaintext secrets to this repository or embedding them into container images. All sensitive values should live exclusively in AWS Secrets Manager.
