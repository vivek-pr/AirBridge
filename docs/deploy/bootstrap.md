# Cluster Bootstrap

Baseline Kubernetes resources required for all AirBridge environments.

## Usage

Apply the manifests:

```bash
kubectl apply -k infra/bootstrap
```

## Namespaces

The kustomization creates the following namespaces with the Kubernetes
[Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
`baseline` profile enforced:

- `airbridge-system`
- `airbridge-control`
- `airbridge-edge`

## Service Accounts and RBAC

Service accounts are provided for the control plane and edge workers.  They
are bound to cluster roles granting the permissions needed by each
component.

## Image Pull Secrets

Docker registry credentials are defined in `infra/bootstrap/registry-creds.yaml`.
Replace the placeholder data or create the secrets manually:

```bash
kubectl create secret docker-registry registry-creds \
  --docker-server=<REGISTRY> \
  --docker-username=<USERNAME> \
  --docker-password=<PASSWORD> \
  --namespace airbridge-control
```

Repeat for each namespace as required.
