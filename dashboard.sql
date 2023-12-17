
--ЗАПРОСЫ В ДАШБОРД

--количество пользователей
select sum(visitors_count) from final_query  

--количество лидов
select sum(leads_count) from final_query

--конверсия в лиды
select round(sum(leads_count)*100.0/sum(visitors_count), 2) from final_query

--конверсия в оплату
select round(sum(purchases_count)*100.0/sum(leads_count), 2) from final_query

--затраты на рекламу
select sum(total_cost) from final_query

--выручка
select sum(revenue) from final_query

--пользователи по неделям и месяцам
select  
	case 
		when visit_date between '2023-06-01' and '2023-06-04' then '01/06-04/06' 
		when visit_date between '2023-06-05' and '2023-06-11' then '05/06-11/06' 
		when visit_date between '2023-06-12' and '2023-06-18' then '12/06-18/06' 
		when visit_date between '2023-06-19' and '2023-06-25' then '19/06-25/06'  
		when visit_date between '2023-06-26' and '2023-06-30' then '26/06-30/06'
	end,
	utm_source,
	sum(visitors_count)
from final_query
group by 1, 2

--пользователи по дням
select 
	visit_date,
	case 
    		when utm_source like 'vk%' then 'vk'
    		when utm_source like '%andex%' then 'yandex'
    		when utm_source like 'twitter%' then 'twitter'
    		when utm_source like '%telegram%' then 'telegram'
    		when utm_source like 'facebook%' then 'facebook'
    		else utm_source end,
	sum(visitors_count)
from final_query
group by 1, 2	
order by 1

--затраты на рекламу
select 
	visit_date,
	utm_source,
	sum(total_cost)
from final_query
where total_cost <> 0
group by 1, 2
order by 1

--CPU (CPL, CPPU и ROI меняется только агрегат, CPL - sum(total_cost) * 1.0/ sum(leads_count), CPPU - sum(total_cost) * 1.0/ sum(purchases_count), ROI - (sum(revenue) - sum(total_cost)) * 1.0/ sum(total_cost))
select round(sum(total_cost)*1.0/sum(visitors_count), 2) from final_query

--CPU source (то же самое с medium и campaign)
select 
	utm_source, 
	round(sum(total_cost)*1.0/sum(visitors_count), 2) as cpu_source 
from final_query 
group by 1 
having round(sum(total_cost)*1.0/sum(visitors_count), 2) is not null

--корреляция Пирсона между затратами и выручкой
select 
	case 
		when utm_source = 'vk' then utm_source
		when utm_source = 'yandex' then utm_source
		else 'else'
	end as utm_source,
	coalesce(sum(total_cost), 0) as total_cost,
	sum(revenue) as revenue,
	round(cast(coalesce(corr(total_cost, revenue), 0) as numeric), 3) as correlation
from final_query
group by 1

 	