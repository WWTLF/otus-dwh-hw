# 

## Настройка 
```
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
export $(xargs <.env)
```

## Структура БД
1. Подключаемся к БД из bach airflow VM: psql -h rc1a-3hidusiqgw9fp410.mdb.yandexcloud.net -p 6432 -U user lesson10
2. Создаем таблицу для хранения результатов
 ```
CREATE TABLE public.iss (
	ts timestamp NOT NULL,
	lat float8 NOT NULL,
	lon varchar NOT NULL,
	CONSTRAINT iss_pk PRIMARY KEY (ts)
);
 ```


 ## DAG

### Задача 1
### Задача 2

Проверяем результат:
