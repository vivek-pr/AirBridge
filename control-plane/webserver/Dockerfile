FROM python:3.11-slim
ENV AIRFLOW_HOME=/opt/airflow AIRFLOW_VERSION=3.0.4
ENV PATH="${AIRFLOW_HOME}/.local/bin:${PATH}"
# (optional) set PY_VER to match base image’s Python
ENV PY_VER=3.11
ENV CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PY_VER}.txt"

RUN set -ex \
    && apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 50000 airflow \
    && useradd  --uid 50000 --gid airflow --home-dir ${AIRFLOW_HOME} --create-home airflow

USER airflow
WORKDIR ${AIRFLOW_HOME}

# Install Airflow and the edge3 provider with matching constraints
RUN pip install --no-cache-dir "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}" \
    && pip install --no-cache-dir "apache-airflow-providers-edge3" --constraint "${CONSTRAINT_URL}"

# Copy your cfg with [core] executor = EdgeExecutor
COPY airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

RUN mkdir -p ${AIRFLOW_HOME}/dags
COPY dags/ ${AIRFLOW_HOME}/dags/

COPY scripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl --fail http://localhost:8080/health || exit 1

CMD ["airflow", "api-server"]
