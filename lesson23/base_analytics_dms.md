Для создания и заполнения таблиц в базе данных PostgreSQL, сначала создадим таблицы с использованием DDL (Data Definition Language), затем вставим данные в таблицы с использованием DML (Data Manipulation Language).

### Полные команды для выполнения:

#### Создание таблиц

```sql
-- Таблица airports
CREATE TABLE airports (
    airport_code CHAR(3) NOT NULL PRIMARY KEY,
    airport_name TEXT NOT NULL,
    country TEXT NOT NULL
);

-- Таблица employee
CREATE TABLE employee (
    employee_id INT NOT NULL,
    employee_name TEXT NOT NULL,
    birth_dt DATE NOT NULL,
    position TEXT NOT NULL,
    salary FLOAT NOT NULL,
    valid_from_dt DATE NOT NULL,
    valid_to_dt DATE NOT NULL DEFAULT '5999-01-01',
    PRIMARY KEY (employee_id, valid_from_dt)
);

-- Таблица flights
CREATE TABLE flights (
    flight_no CHAR(6) NOT NULL,
    employee_id INT NOT NULL,
    scheduled_departure TIMESTAMP NOT NULL,
    scheduled_arrival TIMESTAMP NOT NULL,
    departure_airport CHAR(3) NOT NULL REFERENCES airports(airport_code),
    arrival_airport CHAR(3) NOT NULL REFERENCES airports(airport_code),
    status VARCHAR(20) NOT NULL,
    actual_departure TIMESTAMP NULL,
    actual_arrival TIMESTAMP NULL,
    PRIMARY KEY (flight_no, employee_id, scheduled_departure)
);
```

#### Заполнение таблиц данными

```sql
-- Заполнение таблицы airports
INSERT INTO airports (airport_code, airport_name, country) VALUES
('SVO', 'Sheremetyevo International Airport', 'Russia'),
('DME', 'Domodedovo International Airport', 'Russia'),
('LED', 'Pulkovo Airport', 'Russia'),
('OVB', 'Tolmachevo Airport', 'Russia'),
('VVO', 'Vladivostok International Airport', 'Russia'),
('KZN', 'Kazan International Airport', 'Russia'),
('SVX', 'Koltsovo Airport', 'Russia'),
('AER', 'Sochi International Airport', 'Russia'),
('KJA', 'Yemelyanovo International Airport', 'Russia'),
('UFA', 'Ufa International Airport', 'Russia');

-- Заполнение таблицы employee
INSERT INTO employee (employee_id, employee_name, birth_dt, position, salary, valid_from_dt) VALUES
(1, 'Ivan Ivanov', '1980-01-01', 'Pilot', 5000.00, '2024-01-01'),
(2, 'Petr Petrov', '1985-05-15', 'SFA', 3000.00, '2024-01-01'),
(3, 'Sidor Sidorov', '1990-03-20', 'Steward', 2000.00, '2024-01-01'),
(4, 'Olga Smirnova', '1988-07-10', 'Steward', 2000.00, '2024-01-01'),
(5, 'Elena Nikolaeva', '1992-11-25', 'Pilot', 5000.00, '2024-01-01'),
(6, 'Maria Petrova', '1987-09-12', 'Pilot', 5500.00, '2024-01-01'),
(7, 'Dmitry Antonov', '1991-02-28', 'SFA', 3200.00, '2024-01-01'),
(8, 'Nikita Sergeev', '1983-12-05', 'Steward', 2100.00, '2024-01-01'),
(9, 'Anastasia Fedorova', '1995-06-18', 'Steward', 2100.00, '2024-01-01'),
(10, 'Alexey Kuznetsov', '1989-10-07', 'Pilot', 5500.00, '2024-01-01');

-- Заполнение таблицы flights
INSERT INTO flights (flight_no, employee_id, scheduled_departure, scheduled_arrival, departure_airport, arrival_airport, status, actual_departure, actual_arrival) VALUES
('SU1234', 1, '2024-07-15 08:00:00', '2024-07-15 10:00:00', 'SVO', 'LED', 'Scheduled', NULL, NULL),
('SU1234', 2, '2024-07-15 08:00:00', '2024-07-15 10:00:00', 'SVO', 'LED', 'Scheduled', NULL, NULL),
('SU5678', 3, '2024-07-16 12:00:00', '2024-07-16 16:00:00', 'DME', 'OVB', 'Scheduled', NULL, NULL),
('SU5678', 4, '2024-07-16 12:00:00', '2024-07-16 16:00:00', 'DME', 'OVB', 'Scheduled', NULL, NULL),
('SU9101', 5, '2024-07-17 14:00:00', '2024-07-17 18:00:00', 'LED', 'VVO', 'Scheduled', NULL, NULL),
('SU3456', 1, '2024-07-18 09:00:00', '2024-07-18 11:00:00', 'SVO', 'KZN', 'Scheduled', NULL, NULL),
('SU3456', 2, '2024-07-18 09:00:00', '2024-07-18 11:00:00', 'SVO', 'KZN', 'Scheduled', NULL, NULL),
('SU7890', 3, '2024-07-19 13:00:00', '2024-07-19 17:00:00', 'DME', 'SVX', 'Scheduled', NULL, NULL),
('SU7890', 4, '2024-07-19 13:00:00', '2024-07-19 17:00:00', 'DME', 'SVX', 'Scheduled', NULL, NULL),
('SU4321', 5, '2024-07-20 15:00:00', '2024-07-20 19:00:00', 'LED', 'AER', 'Scheduled', NULL, NULL),
('SU4321', 6, '2024-07-20 15:00:00', '2024-07-20 19:00:00', 'LED', 'AER', 'Scheduled', NULL, NULL),
('SU6543', 7, '2024-07-21 07:00:00', '2024-07-21 11:00:00', 'OVB', 'KJA', 'Scheduled', NULL, NULL),
('SU6543', 8, '2024-07-21 07:00:00', '2024-07-21 11:00:00', 'OVB', 'KJA', 'Scheduled', NULL, NULL),
('SU8765', 9, '2024-07-22 08:00:00', '2024-07-22 10:00:00', 'VVO', 'UFA', 'Scheduled', NULL, NULL),
('SU8765', 10, '2024-07-22 08:00:00', '2024-07-22 10:00:00', 'VVO', 'UFA', 'Scheduled', NULL, NULL);
```

Можно генеировать дополнительные данные для решения задачи.
Схема данных для представленных таблиц, где показаны связи между таблицами и ключевые поля:

```plaintext
        +----------------------+
        |      airports        |
        +----------------------+
        | airport_code (PK)    |
        | airport_name         |
        | country              |
        +----------------------+
                  |
                  | 1
                  |
                  | N
        +----------------------+
        |       flights        |
        +----------------------+
        | flight_no (PK)       |
        | employee_id (PK, FK) |
        | scheduled_departure (PK) |
        | scheduled_arrival    |
        | departure_airport (FK)   |
        | arrival_airport (FK)     |
        | status              |
        | actual_departure    |
        | actual_arrival      |
        +----------------------+
                  |
                  | N
                  |
                  | 1
        +----------------------+
        |      employee        |
        +----------------------+
        | employee_id (PK)     |
        | employee_name        |
        | birth_dt             |
        | position             |
        | salary               |
        | valid_from_dt (PK)   |
        | valid_to_dt          |
        +----------------------+
```

### Описание связей:

1. **airports -> flights**:
   - Один аэропорт может быть пунктом вылета или пунктом прибытия для многих рейсов.
   - Поля `departure_airport` и `arrival_airport` в таблице `flights` ссылаются на поле `airport_code` в таблице `airports`.

2. **employee -> flights**:
   - Один сотрудник может быть назначен на многие рейсы, но каждая запись рейса уникальна для комбинации `flight_no`, `employee_id`, и `scheduled_departure`.
   - Поле `employee_id` в таблице `flights` ссылается на поле `employee_id` в таблице `employee`.

### Объяснение:

- **Таблица `airports`** содержит справочную информацию о аэропортах.
- **Таблица `employee`** содержит информацию о сотрудниках, с версионностью для отслеживания изменений атрибутов сотрудников.
- **Таблица `flights`** содержит информацию о рейсах, включая данные о назначенных сотрудниках, времени вылета и прилёта, и статусе рейса.

Схема данных в таком виде наглядно демонстрирует взаимосвязи между таблицами и ключевые поля, которые обеспечивают целостность данных и правильное функционирование базы данных.