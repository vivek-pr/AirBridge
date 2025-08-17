# Deploy Edge Worker with Helm

Install the AirBridge edge worker on a customer Kubernetes cluster using the provided Helm chart.

## Prerequisites
- Kubernetes cluster with network access to the control plane
- Secret containing a control plane token
- Helm 3 installed

## Installation

```bash
helm install my-worker infra/helm/edge-worker \
  --set queue=my-queue \
  --set controlPlane.url=https://cp.example.com \
  --set controlPlane.tokenSecret.name=edge-token \
  --set controlPlane.tokenSecret.key=token
```

The `queue` value binds the worker to a specific execution queue. Update the `controlPlane` settings to match your environment.

## Deployment Mode

The chart runs as a `Deployment` by default. To run a worker on every node, set:

```bash
--set mode=daemonset
```

## Metrics

Enable Prometheus metrics with:

```bash
--set metrics.enabled=true
```

A `ServiceMonitor` can be created for scraping by setting:

```bash
--set metrics.enabled=true --set metrics.serviceMonitor.enabled=true
```

## Tenant Values Example

An example values file demonstrating tenant-scoped configuration is available at `infra/helm/edge-worker/values-tenant.yaml`.

```bash
helm install tenant-a infra/helm/edge-worker -f infra/helm/edge-worker/values-tenant.yaml
```

## Verification

After installation, verify the worker is ready:

```bash
kubectl get pods
```

The pod should register with the control plane and heartbeat successfully.
