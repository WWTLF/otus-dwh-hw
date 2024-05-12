# 

## Настройка 
```
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
export $(xargs <.env)
```

## Структура БД

 ```
CREATE TABLE public.iss (
	ts timestamp NOT NULL,
	lat float8 NOT NULL,
	lon varchar NOT NULL,
	CONSTRAINT iss_pk PRIMARY KEY (ts)
);
 ```