# Makefile, Control Plane, and Data Plane Overview

The project separates responsibilities into a control plane that hosts the
Airflow webserver, scheduler, and triggerer, and a lightweight data plane that
executes DAG tasks on edge workers.  The top-level `Makefile` orchestrates these
components:

- **build-control-plane** – builds Docker images for the webserver, scheduler and
  triggerer.
- **minikube-up / minikube-down** – starts or stops a local Minikube cluster and
  deploys the control plane Helm chart.
- **build-edge-worker** – builds the data plane worker image.
- **run-edge-worker** – launches the worker image locally for quick validation.

The control plane exposes APIs for edge workers to fetch configuration and
report status. Edge workers use the bootstrap script and the corrected
`edge_worker` command to connect to the control plane and execute DAG tasks.
