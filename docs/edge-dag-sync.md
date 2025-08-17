# Edge DAG Synchronization

Edge workers require local copies of DAG files identical to those in the control plane. Use an S3 sync job or sidecar to mirror the control plane's DAG bucket onto each edge node.

## Sidecar container

Run the provided `edge-dag-sync.sh` script in a companion container alongside the edge worker. The script continuously executes `aws s3 sync` with exponential backoff and verifies file integrity via checksums:

```bash
# example Docker invocation
DAG_BUCKET=my-dag-bucket \
DAGS_FOLDER=/opt/airflow/dags \
docker run --rm -e DAG_BUCKET -e DAGS_FOLDER \
  -v /opt/airflow/dags:/opt/airflow/dags \
  amazon/aws-cli:2.13.5 /edge-dag-sync.sh
```

Environment variables:

- `DAG_BUCKET` – S3 bucket containing DAGs (required)
- `DAG_PREFIX` – optional prefix within the bucket
- `DAGS_FOLDER` – local destination, defaults to `/opt/airflow/dags`
- `INTERVAL_SECONDS` – sleep interval after successful sync (default 60)
- `RETRIES` – maximum consecutive failures before exit (default 5)

## Kubernetes CronJob

For periodic one-off syncs, deploy `infra/edge/dag-sync-cronjob.yaml`. It runs `aws s3 sync --checksum --delete` once per minute and retries with exponential backoff on failure. Mount the same volume as the edge worker so both see identical DAG files.

## IAM

Grant the sync container read access to the DAG bucket (`s3:ListBucket` and `s3:GetObject`). In cloud environments, prefer attaching an IAM role to the pod or node rather than baking static credentials into the image. If a different account hosts the bucket, configure role assumption with `AWS_ROLE_ARN` and `AWS_WEB_IDENTITY_TOKEN_FILE` or similar mechanisms.

With the sync job or sidecar in place, edge nodes maintain the same DAG set as the control plane and transient network outages trigger retries with increasing delays.
