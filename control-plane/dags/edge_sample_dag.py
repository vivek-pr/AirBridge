"""Example DAG demonstrating EdgeExecutor usage.

This DAG is designed for environments that run tasks on the EdgeExecutor.
Each task explicitly targets the ``edge`` queue so it will be picked up by
edge workers. The workflow contains two simple tasks with a clear
upstream/downstream relationship.
"""

from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator


def _finish() -> None:
    """Log completion of the DAG."""
    print("Edge sample DAG finished")


with DAG(
    dag_id="edge_sample_dag",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["edge", "example"],
) as dag:
    start = BashOperator(
        task_id="start",
        bash_command="echo 'Start edge sample DAG'",
        queue="edge",
    )

    finish = PythonOperator(
        task_id="finish",
        python_callable=_finish,
        queue="edge",
    )

    start >> finish
