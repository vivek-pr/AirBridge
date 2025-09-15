FROM python:3.12-alpine3.21

ARG PY_VER=3.12
ENV AIRFLOW_HOME=/opt/airflow \
    AIRFLOW_VERSION=3.0.4
ENV PATH="${AIRFLOW_HOME}/.local/bin:${PATH}"


# Install curl and create non-root user
RUN set -ex \
    && apk add --no-cache bash curl ca-certificates tzdata libstdc++ openssl libffi \
    && apk add --no-cache --virtual .build-deps build-base linux-headers openssl-dev libffi-dev cargo \
    && addgroup -S -g 50000 airflow \
    && adduser -S -D -u 50000 -G airflow -h ${AIRFLOW_HOME} airflow \
    && mkdir -p ${AIRFLOW_HOME} && chown -R airflow:airflow ${AIRFLOW_HOME}

USER airflow
WORKDIR ${AIRFLOW_HOME}

# Install Airflow and providers
COPY requirements.lock requirements.lock
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PY_VER}.txt" \
    && echo "Using constraints: ${CONSTRAINT_URL}" \
    && curl -fsSL "${CONSTRAINT_URL}" -o /tmp/constraints.txt \
    && sed -i 's/^Flask==.*/Flask==2.3.3/' /tmp/constraints.txt \
    && sed -i 's/^Werkzeug==.*/Werkzeug==3.0.6/' /tmp/constraints.txt \
    && sed -i 's/^cryptography==.*/cryptography==44.0.1/' /tmp/constraints.txt \
    && pip install --no-cache-dir -r requirements.lock --constraint /tmp/constraints.txt \
    && pip check

USER root
RUN apk del .build-deps
USER airflow

COPY worker/entrypoint.sh /entrypoint.sh
COPY worker/diag.sh /usr/local/bin/diag

ENTRYPOINT ["/entrypoint.sh", "airflow"]
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl --fail --proto '=http' --tlsv1.2 "${CONTROL_PLANE_URL:-https://localhost:8080}/api/v2/monitor/health" || exit 1

CMD ["edge", "worker"]
