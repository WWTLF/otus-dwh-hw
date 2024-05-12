from datetime import timedelta, datetime

# [START import_module]
# The DAG object; we'll need this to instantiate a DAG
from airflow import DAG
# Operators; we need this to operate!
from airflow.sensors.http_sensor import HttpSensor
from airflow.utils.dates import days_ago

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


request_lat_lon =  HttpSensor(
    task_id='request_lat_lon',
    http_conn_id='http_default',
    endpoint='http://api.open-notify.org/iss-now.json',
    request_params={},        
    dag=dag,
)

request_lat_lon