# Deploy Edge Worker with Helm

Install the AirBridge edge worker on a customer Kubernetes cluster using the provided Helm chart.

## Prerequisites
- Kubernetes cluster with outbound HTTPS access to the control-plane API (port 443). Workers may sit behind NAT or egress-only firewalls.
- No inbound firewall rules are required; the worker initiates all connections.
- Control plane token stored in AWS Secrets Manager
- Helm 3 installed

## Installation

```bash
helm install my-worker infra/helm/edge-worker \
  --set queue=my-queue \
  --set controlPlane.url=https://cp.example.com \
  --set controlPlane.tokenSecretId=edge-token-id
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

## Network Validation

To validate operation behind strict firewalls, deploy the worker with all inbound rules blocked. The pod should still register and heartbeat with the control plane because it only requires outbound TLS connections. If metrics are enabled, open the metrics port to allow scraping; otherwise no inbound ports are needed.

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
