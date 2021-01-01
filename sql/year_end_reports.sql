select year(date_added) as year, WEEKOFYEAR(date_added) as week, count(*) as number_of_ms 
from manuscripts
where shelfmark not like "Arch.Cap.S.Pietro%" and date_added >= "2018-01-22" 
group by 1,2;

select shelfmark, weekofyear(date_Added) from manuscripts
where shelfmark like "vat.lat%" and date_added >= "2019-01-01"
order by date_added;
