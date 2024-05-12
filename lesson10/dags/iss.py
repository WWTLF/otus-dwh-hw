from datetime import timedelta, datetime
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
from airflow.operators.postgres_operator import PostgresOperator
import requests


def request_lat_lon(): 
    r = requests.get('http://api.open-notify.org/iss-now.json')
    return r.json()

    

default_args = {
        'owner' : 'airflow',
        'start_date' : datetime(2022, 11, 12),
}

dag = DAG(
    'iss',    
    description='Otus Lab lesson 10',
    schedule_interval=timedelta(days=1),
    default_args=default_args,
)

get_position = PythonOperator(
    task_id='request_lat_lon',
    python_callable= request_lat_lon,
    dag=dag
)

save_postion = PostgresOperator(
    task_id="save_postion",
    postgres_conn_id="otus_lab",
    sql="SELECT * FROM iss",
    parameters={"begin_date": "2020-01-01", "end_date": "2020-12-31"},
    dag=dag
)

get_position >> save_postion