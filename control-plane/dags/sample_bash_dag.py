from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator

with DAG(
    dag_id="sample_bash_dag",
    start_date=datetime(2024, 1, 1),
    schedule="@daily",
    catchup=False,
) as dag:
    BashOperator(
        task_id="print_hello",
        bash_command="echo 'Hello from sample DAG'",
    )
