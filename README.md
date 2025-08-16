# AirBridge
Build a control-plane/data-plane Airflow on 3.0.4 using Edge Executor. Control plane hosts web/API, scheduler, triggerer, DB; data planes run lightweight edge workers with outbound-only HTTPS. DAGs and logs are centralized in S3.

## Building and Testing

The control-plane services (webserver, scheduler, and triggerer) are built as Docker images. Use the Makefile to build all three:

```
make build-control-plane
```

Each image runs an entrypoint that performs `airflow db migrate` before starting the service. The CI workflow builds these images and verifies that the Airflow CLI is available to prevent regressions.
