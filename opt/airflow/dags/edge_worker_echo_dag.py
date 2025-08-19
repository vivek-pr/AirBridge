from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator


def _echo(**context):
    print("edge worker executed")


with DAG(
    dag_id="edge_worker_echo_dag",
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
) as dag:
    PythonOperator(task_id="echo", python_callable=_echo)
