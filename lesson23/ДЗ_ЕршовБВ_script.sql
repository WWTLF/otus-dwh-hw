
with f as (
	select 
	employee_id,
	scheduled_departure,
	scheduled_arrival,
	departure_airport,
	arrival_airport,
	status,
	-- Певрое что делаем, это устанавливаем фактические даты вылета и прилета, так как они заполнены NULL, считаем что NULL значит по расписанию
	case 
		when actual_departure is null then scheduled_departure
		else actual_departure	
	end as f_actual_departure,
	case 
		when actual_arrival is null then scheduled_arrival
		else actual_arrival	
	end as f_actual_arrival,
	dep_airport.country as dep_country,
	arr_airport.country as arr_country
	from flights f 
	inner join airports dep_airport on f.departure_airport = dep_airport.airport_code
	inner join airports arr_airport on f.arrival_airport = arr_airport.airport_code
	where status = 'Arrived'
), 
versioned_flights as (
select 
	f.employee_id,
-- Находим последнюю версию сотрудника непосредственно перед фактической датой вылета, так как в задании сказано, что если ставка менялась во время полета, она не применятеся
(select e.valid_from_dt from employee e where 
	e.employee_id = f.employee_id and
	e.valid_from_dt <= f.f_actual_departure 
	order by e.valid_from_dt desc limit 1) as epm_valid_from_dt, -- Важно отсортировать по убыванию valid_from
(select e.salary from employee e where 
	e.employee_id = f.employee_id and
	e.valid_from_dt <= f.f_actual_departure 
	order by e.valid_from_dt desc limit 1) as salary, -- Важно отсортировать по убыванию valid_from
-- Находим коэф.
case 
	when dep_country <> 'Russia' then 1.2
	when arr_country <> 'Russia' then 1.2
	else 1.0
end as rate,
EXTRACT(HOUR FROM AGE(f.f_actual_arrival, f.f_actual_departure)) as flight_duration,
f.f_actual_departure,
f.f_actual_arrival

from f order by employee_id, epm_valid_from_dt),
flight_costs as (
	select 
	employee_id, 
	epm_valid_from_dt,
	f_actual_departure,
	(salary * rate * flight_duration) as total_cost,
	date_trunc('month', f_actual_departure) as flight_month
	from versioned_flights
)

select e.employee_id, 
e.position,
salary,
count(*) as flight_cnt,
sum(flight_costs.total_cost) as salary_gross,
flight_month as valid_from_dttm,
flight_month + interval '1 month' as valid_to_dttm


from employee e 
	left join flight_costs on  flight_costs.employee_id = e.employee_id and flight_costs.epm_valid_from_dt = e.valid_from_dt
	
group by e.employee_id,e.position, salary, valid_from_dttm, valid_to_dttm
order by e.employee_id, valid_from_dttm
