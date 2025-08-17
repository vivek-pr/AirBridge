from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator


with DAG(
    dag_id="example_dag",
    start_date=datetime(2023, 1, 1),
    schedule_interval="@once",
    catchup=False,
) as dag:
    BashOperator(task_id="hello", bash_command="echo 'Hello from AirBridge'")
