# DAG Sync SLA

AirBridge synchronizes DAG definitions from an S3 bucket to the control plane's `DAGS_FOLDER` using a Kubernetes CronJob.
The job runs `aws s3 sync` on a shared volume so Airflow components read DAG files locally, avoiding any direct S3 mounts.

The CronJob executes every minute and skips overlapping runs (`concurrencyPolicy: Forbid`). If a sync fails, the job
retries with exponential backoff. With the default schedule, new or updated DAGs propagate to the control plane within two
minutes.

