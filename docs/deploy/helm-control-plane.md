# AirBridge Control Plane Helm Chart

This chart deploys the AirBridge control plane (Airflow webserver, scheduler, and triggerer)
into a Kubernetes cluster. The database is expected to be managed externally.

## Usage

Choose the values file for your environment and install with Helm:

```bash
helm install airbridge-control-plane infra/helm/airbridge -f infra/helm/airbridge/values-dev.yaml
```

Replace `values-dev.yaml` with `values-stage.yaml` or `values-prod.yaml` for other
environments.

## Configuration

* **Airflow configuration** – provided via `airflow.config` and mounted as `airflow.cfg`.
* **Optional components** – enable Flower by setting `flower.enabled=true`.
* **Scaling** – HPAs and PodDisruptionBudgets are controlled via values for each component.

See `infra/helm/airbridge/values.yaml` for the full list of configurable values.
