# Local Kubernetes Development

This guide describes how to run the AirBridge control plane on a local Kubernetes
cluster using [kind](https://kind.sigs.k8s.io/) or Minikube.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [kind](https://kind.sigs.k8s.io/) or [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [Helm](https://helm.sh/)

## Quickstart

```bash
make kind-up
```

The command above creates a kind cluster, builds the control plane images, loads
them into the cluster and deploys the Helm chart.

To stop the cluster:

```bash
make kind-down
```

## Accessing the UI

Port-forward the webserver service to reach the AirBridge UI locally:

```bash
kubectl port-forward service/airbridge-control-plane-webserver 8080:8080
```

Then open <http://localhost:8080> in your browser.

## Running the Sample DAG

A sample DAG is located in `samples/example_dag.py`. Upload it to the webserver
via the AirBridge UI and trigger it to verify the installation.
