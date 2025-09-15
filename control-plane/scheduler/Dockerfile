FROM python:3.12-alpine3.21
ARG PY_VER=3.12
ENV AIRFLOW_HOME=/opt/airflow AIRFLOW_VERSION=3.0.6
ENV PATH="${AIRFLOW_HOME}/.local/bin:${PATH}"

RUN set -ex \
    && apk add --no-cache bash curl ca-certificates tzdata libstdc++ openssl libffi \
    && apk add --no-cache --virtual .build-deps build-base linux-headers openssl-dev libffi-dev cargo \
    && addgroup -S -g 50000 airflow \
    && adduser -S -D -u 50000 -G airflow -h ${AIRFLOW_HOME} airflow \
    && mkdir -p ${AIRFLOW_HOME} && chown -R airflow:airflow ${AIRFLOW_HOME}

USER airflow
WORKDIR ${AIRFLOW_HOME}

# Install Airflow and required providers with matching constraints
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PY_VER}.txt" \
    && echo "Using constraints: ${CONSTRAINT_URL}" \
    && curl -fsSL "${CONSTRAINT_URL}" -o /tmp/constraints.txt \
    && sed -i 's/^Flask==.*/Flask==2.3.3/' /tmp/constraints.txt \
    && sed -i 's/^Werkzeug==.*/Werkzeug==3.0.6/' /tmp/constraints.txt \
    && sed -i 's/^cryptography==.*/cryptography==44.0.1/' /tmp/constraints.txt \
    && pip install --no-cache-dir \
        "apache-airflow==${AIRFLOW_VERSION}" \
        "apache-airflow-providers-amazon" \
        "apache-airflow-providers-edge3" \
        --constraint /tmp/constraints.txt \
    && pip install --no-cache-dir apache-airflow[postgres]==${AIRFLOW_VERSION} --constraint /tmp/constraints.txt \
    && pip check

USER root
RUN apk del .build-deps
USER airflow

# Copy your cfg with [core] executor = EdgeExecutor
COPY airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

COPY scripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD airflow jobs check --job-type SchedulerJob || exit 1

CMD ["airflow", "scheduler"]
