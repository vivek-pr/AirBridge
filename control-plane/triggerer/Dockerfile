FROM python:3.11-slim

ENV AIRFLOW_HOME=/opt/airflow \
    AIRFLOW_VERSION=3.0.4
ENV PATH="${AIRFLOW_HOME}/.local/bin:${PATH}"

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 50000 airflow \
    && useradd --uid 50000 --gid airflow --home-dir ${AIRFLOW_HOME} --create-home airflow

USER airflow
WORKDIR ${AIRFLOW_HOME}

# Install Airflow and required providers
RUN pip install --no-cache-dir \
    "apache-airflow==${AIRFLOW_VERSION}" \
    "apache-airflow-providers-amazon" \
    "apache-airflow-providers-edge3"

RUN pip install --no-cache-dir apache-airflow[postgres]==${AIRFLOW_VERSION}

COPY airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

COPY scripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD airflow jobs check --job-type TriggererJob || exit 1

CMD ["airflow", "triggerer"]
