## 2025-09-15

Summary: Hardened all AirBridge Docker images against known CVEs and reduced image footprint by migrating to Alpine Python 3.12; upgraded vulnerable/transitive Python dependencies with special attention to Flask/Werkzeug and cryptography compatibility with Airflow 3.0.4.

Changes

- Base images: switched all Dockerfiles to `python:3.12-alpine3.21`.
- OS packages: replaced `apt` with `apk`; installed `bash`, `curl`, `ca-certificates`, `tzdata` only.
- Airflow: kept `apache-airflow==3.0.4` across all images for API stability.
- Constraints: still use official Airflow constraints for Python 3.12, then apply targeted upgrades.
- Python deps (security):
  - `Werkzeug==3.0.6` (addresses CVEs and incompatibilities in 2.x).
  - `cryptography==44.0.1` (addresses multiple OpenSSL binding CVEs).
  - `Flask>=2.3,<3.0` to satisfy compatibility with `Werkzeug 3.x`.
- Triggerer image now installs with Airflow constraints (previously unconstrained) for consistent resolution.
- Added `pip check` to fail the build if dependency conflicts remain.

Fixes after initial Alpine migration

- Addressed build failures for `grpcio` on Alpine (missing C++ toolchain):
  - Add temporary build deps: `build-base`, `linux-headers`, `openssl-dev`, `libffi-dev`, `cargo` via a virtual package `.build-deps`.
  - Keep runtime libs: `libstdc++`, `openssl`, `libffi`.
- Remove `.build-deps` after `pip install` to keep the final image small.

Worker image note (Ray on Alpine)

- Dropped `apache-airflow-providers-google` from `data-plane/requirements.lock` for the default Alpine-based worker because it pulls `ray` (>=2.42), which does not provide compatible musllinux wheels for Alpine and is impractical to build from source.
- If you need Google provider tasks on workers, build a separate worker image on Debian slim (glibc) or maintain a GCP-specific worker variant and keep the default worker lean.

Rationale and Compatibility Notes

- Airflow 3.0.4 upstream constraints pin `Flask==2.2.5`, `Werkzeug==2.2.3`, `cryptography==42.0.8`. These are outdated and can be flagged by scanners (Trivy/Grype).
- `Werkzeug 3.x` requires `Flask>=2.3`. We therefore upgrade Flask alongside Werkzeug while keeping Airflow at 3.0.4. In practice Airflow 3.0.4 works with Flask 2.3.x in testing, but it is out-of-constraints; we enforce a smoke test regimen (below) to validate.
- If any transitive constraint conflict arises in your environment, consider building or relaxing the specific dependency that blocks Flask/Werkzeug upgrade (e.g., pinning `Flask-AppBuilder` to a compatible 4.6+ or re-building with relaxed constraints). The base images include only minimal OS libs; wheels are expected for musl.

Build/Run Validation

1) Build images
   - `make build-control-plane`
   - `make build-edge-worker`

2) Initialize DB (webserver or scheduler container)
   - `docker run --rm -e AIRFLOW_HOME=/opt/airflow airbridge-webserver:3.0.4 airflow db init`
   - or: `docker run --rm airbridge-scheduler:3.0.4 airflow db init`

3) Smoke tests
   - Webserver/API: `docker run --rm -p 8080:8080 airbridge-webserver:3.0.4 airflow api-server`
   - Scheduler: `docker run --rm airbridge-scheduler:3.0.4 airflow jobs check --job-type SchedulerJob`
   - Triggerer: `docker run --rm airbridge-triggerer:3.0.4 airflow jobs check --job-type TriggererJob`
   - Worker: `docker run --rm airbridge-edge-worker:3.0.4 airflow --help` (plus edge diag via `diag`)

4) Auth/session validation
   - Verify login/session flows in the web UI and FastAPI endpoints (JWT); focus on CSRF/session cookie handling and 302 flows.

5) DAG parsing/execution
   - Copy DAGs into the pods or mount locally; ensure parsing succeeds (`airflow dags list`), and run a simple DAG end-to-end.

Security Scanning

- Trivy: `trivy image --ignore-unfixed airbridge-webserver:3.0.4` (repeat for other images)
- Grype: `grype airbridge-webserver:3.0.4` (repeat for other images)
- Expect substantially reduced OS CVEs vs. Debian slim; Python package CVEs addressed via explicit upgrades above.

Rollback Instructions

- Revert Dockerfiles to Debian slim and original constraints:
  - Change `FROM python:3.12-alpine3.21` back to `python:3.11-slim`.
  - Replace `apk` install lines with the original `apt-get` blocks.
  - Remove the explicit `pip install --upgrade` for `Werkzeug`, `Flask`, and `cryptography`.
  - For the triggerer, remove the constraints usage if you prefer the original behavior.
- Alternatively, checkout the previous commit in VCS or restore the saved Dockerfiles.

Notes

- If any provider or transitive dep rejects `Flask>=2.3`, pin that package to a compatible version or rebuild it with relaxed constraints. `pip check` in the Dockerfiles will force a hard failure to catch such cases early.
