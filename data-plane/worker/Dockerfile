FROM python:3.11-slim

ENV AIRFLOW_HOME=/opt/airflow \
    AIRFLOW_VERSION=3.0.4 \
    PY_VER=3.11 \
    PATH="${AIRFLOW_HOME}/.local/bin:${PATH}" \
    CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PY_VER}.txt"

# Install curl and create non-root user
RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 50000 airflow \
    && useradd --uid 50000 --gid airflow --home-dir ${AIRFLOW_HOME} --create-home airflow

USER airflow
WORKDIR ${AIRFLOW_HOME}

# Install Airflow and providers
COPY requirements.lock requirements.lock
RUN pip install --no-cache-dir -r requirements.lock --constraint "${CONSTRAINT_URL}"

COPY worker/entrypoint.sh /entrypoint.sh
COPY worker/diag.sh /usr/local/bin/diag

ENTRYPOINT ["/entrypoint.sh", "airflow"]
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl --fail --proto '=https' --tlsv1.2 "${CONTROL_PLANE_URL:-https://localhost:8080}/health" || exit 1

CMD ["edge-worker"]
