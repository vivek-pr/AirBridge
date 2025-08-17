# AirBridge
Build a control-plane/data-plane Airflow on 3.0.4 using Edge Executor. Control plane hosts web/API, scheduler, triggerer, DB; data planes run lightweight edge workers with outbound-only HTTPS. DAGs and logs are centralized in S3.

The Helm chart optionally synchronizes DAGs from S3 to the cluster using either a
`CronJob` or a sidecar container controlled by `.Values.dagSync` settings.

## Building and Testing

The control-plane services (webserver, scheduler, and triggerer) are built as Docker images. Use the Makefile to build all three:

```
make build-control-plane
```

Each image runs an entrypoint that performs `airflow db migrate` before starting the service. The CI workflow builds these images and verifies that the Airflow CLI is available to prevent regressions.

A minimal edge-worker image is also provided:

```
make build-edge-worker
```

The worker runs as a non-root user, accepts configuration via environment variables (including `CONTROL_PLANE_TOKEN` or `CONTROL_PLANE_TOKEN_FILE` for token injection), and ships with a `diag` script to test connectivity to the control-plane API.

## Edge sample DAG

An example DAG demonstrating the **EdgeExecutor** is provided in
`opt/airflow/dags/edge_sample_dag.py`.

### Deploy
1. Copy the DAG file to your Airflow instance, e.g.:
   ```bash
   cp opt/airflow/dags/edge_sample_dag.py /opt/airflow/dags/
   ```
2. Configure Airflow to use the executor:
   ```bash
   export AIRFLOW__CORE__EXECUTOR=edge_executor.EdgeExecutor
   ```
3. Start the scheduler and webserver so the DAG appears in the UI.

### Run
- **Web UI:** enable the DAG and click *Trigger DAG*.
- **CLI:**
  ```bash
  airflow dags trigger edge_sample_dag
  ```
- **Smoke tests:**
  ```bash
  airflow tasks test edge_sample_dag start 2024-01-01
  airflow tasks test edge_sample_dag finish 2024-01-01
  ```

### Troubleshooting
- DAG not showing up? Ensure it resides in Airflow's `dags_folder`
  (default `/opt/airflow/dags`).
- Import errors? Check the scheduler logs for stack traces.
- Missing dependencies? Verify the worker image contains this project and
  Airflow can import the operators used in the DAG.
