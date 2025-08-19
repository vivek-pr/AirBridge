import os
import subprocess
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DAG_FILE = PROJECT_ROOT / "opt" / "airflow" / "dags" / "edge_worker_echo_dag.py"


def test_control_plane_triggers_edge_worker(tmp_path):
    subprocess.run(
        [sys.executable, "-m", "pip", "install", PROJECT_ROOT.as_posix()],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
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

    # Run the DAG using the executor to simulate end-to-end execution
    dag_script = DAG_FILE.read_text() + "\ndag.test(run_after=None, use_executor=True)\n"
    subprocess.run(
        [sys.executable, "-c", dag_script],
        check=True,
        cwd=tmp_path,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
