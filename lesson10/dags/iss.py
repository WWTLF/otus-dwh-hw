from datetime import timedelta, datetime

# [START import_module]
# The DAG object; we'll need this to instantiate a DAG
from airflow import DAG
# Operators; we need this to operate!
# from airflow.providers.http.operators.http import SimpleHttpOperator
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
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

t1 = PythonOperator(
    task_id='request_lat_lon',
    python_callable= request_lat_lon,
    dag=dag
)

t1