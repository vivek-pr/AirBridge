import os
import subprocess
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]


def test_dag_runs_with_edge_executor(tmp_path):
    """A simple DAG should execute using EdgeExecutor."""
    subprocess.run(
        [sys.executable, "-m", "pip", "install", PROJECT_ROOT.as_posix()],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )

    dag_script = (
        "from datetime import datetime\n"
        "from airflow import DAG\n"
        "from airflow.operators.empty import EmptyOperator\n"
        "with DAG('edge_test', start_date=datetime(2024,1,1), schedule=None) as dag:\n"
        "    EmptyOperator(task_id='t1')\n"
        "dag.test(run_after=None, use_executor=True)\n"
    )

    env = os.environ.copy()
    env.pop("PYTHONPATH", None)
    env["AIRFLOW__CORE__EXECUTOR"] = "edge_executor.EdgeExecutor"
    env["AIRFLOW_HOME"] = str(tmp_path)
    env["AIRFLOW__DATABASE__SQL_ALCHEMY_CONN"] = f"sqlite:///{tmp_path/'airflow.db'}"

    subprocess.run(
        [sys.executable, "-m", "airflow", "db", "migrate"],
        check=True,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )

    subprocess.run(
        [sys.executable, "-c", dag_script],
        check=True,
        cwd=tmp_path,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
