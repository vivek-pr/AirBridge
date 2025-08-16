# Version Compatibility Matrix

AirBridge pins all components to specific versions to ensure reproducible builds and strict parity between the control plane and edge workers.

| Component      | Apache Airflow | Providers (amazon, google, postgres) |
|----------------|----------------|---------------------------------------|
| Control Plane  | 3.0.4          | amazon 9.12.0, google 17.1.0, postgres 6.2.3 |
| Edge Worker    | 3.0.4          | amazon 9.12.0, google 17.1.0, postgres 6.2.3 |

## Upgrade Policy

- Lock files in `control-plane/` and `data-plane/` define the only supported dependency set.
- Version bumps require updating the matrix and regenerating both lock files in a single pull request.
- Control plane must be upgraded and validated before rolling out changes to edge workers.

## Rolling Upgrade Strategy

1. Build and deploy a new control-plane image from the updated lock file.
2. Verify scheduler and webserver health on the control plane.
3. Roll out edge worker images gradually, monitoring task success and logs.
4. Keep older edge workers no more than one minor release behind the control plane.
5. For quick rollback, retain the previous lock files and container images.
