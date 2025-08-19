from pathlib import Path

from airflow.models.dagbag import DagBag

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DAG_PATH = PROJECT_ROOT / "opt" / "airflow" / "dags"


def test_edge_worker_echo_dag_loaded():
    dagbag = DagBag(dag_folder=str(DAG_PATH), include_examples=False)
    assert "edge_worker_echo_dag" in dagbag.dags
    dag = dagbag.dags["edge_worker_echo_dag"]
    assert set(dag.task_ids) == {"echo"}
