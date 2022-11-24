select *
from "covid-deaths";

select *
from "covid-vaccinations";
-------GOOD TO GO----

select "location", "date", "total_cases", "new_cases", "total_deaths", "population"
from "covid-deaths"
order by 1,2;

--- TOTAL CASES VS TOTAL DEATHS----
select "location", "date", "total_cases", "total_deaths",("total_deaths"/"total_cases")*100 as "death_percentage" 
from "covid-deaths"
order by 1,2;

--PERCENTAGE OF PEOPLE DYING FROM COVID IN AFRICA---
select "location", "date", "population", "total_cases", "total_deaths", ("total_deaths"/"total_cases")*100 as "death_percentage" 
from "covid-deaths"
where location like '%Africa%'
order by 1,2;

---TOTAL CASES VS POPULATION
----shows the percentage of population in Africa got covid-----

select "location", "date", "total_cases", "population",("total_cases"/"population")*100 as "death_percentA" 
from "covid-deaths"
where location like '%Africa%'
order by 1,2;

----HIGHEST INFECTION RATE------
---compared to population--

select "location", "population", max("total_cases") as "Highestinfection_count", max(("total_cases"/"population"))*100 as "percentofinfected_popu" 
from "covid-deaths"
where location like '%Africa%'
group by "location", "population"																						  
order by "percentofinfected_popu" desc;

---LOCATION WITH HIGHEST DEATH COUNT PER POPULATION---
select "location", max("total_deaths") as "totaldeathscount" 
from "covid-deaths"
where location like '%Africa%'
group by "location"																						  
order by "totaldeathscount" desc;

---CONTINENT WITH HIGHEST DEATH COUNT--

select "continent", max(cast("total_deaths" as int)) as "totaldeathscount" 
from "covid-deaths"
where continent is not null
group by "continent"																						  
order by "totaldeathscount" desc;


select "continent", max(cast("total_deaths" as int)) as "totaldeathscount" 
from "covid-deaths"
--where "continent" like '%states%'
where continent is not null
group by "continent"																						  
order by "totaldeathscount" desc;

---GLOBAL NUMBERS---

select "date", sum("new_cases")--, "total_cases", "total_deaths" ,("total_deaths"/"total_cases")*100 as "death_percentA" 
from "covid-deaths"
--where location like '%Africa%'
where "continent" is not NULL
group by "date"
order by 1,2
limit 10;


select "date", sum("new_cases") as "total_cases", sum(cast("new_deaths" as int)) as "total_deaths", 
sum(cast("new_deaths" as int))/sum("new_cases")*100 as "Deathpercentage" 
from "covid-deaths"
--where location like '%Africa%'
where "continent" is not NULL
group by "date"
order by 1,2;

select sum("new_cases") as "total_cases", sum(cast("new_deaths" as int)) as "total_deaths", 
sum(cast("new_deaths" as int))/sum("new_cases")*100 as "Deathpercentage" 
from "covid-deaths"
--where location like '%Africa%'
where "continent" is not NULL
group by "date"
order by 1,2;
--------------------------------------------------------------------------					  
----looking at total population vs vaccination

select *
from "covid-deaths" d
join "covid-vaccinations" v
on d.location = v.location
and d.date = v.date;

select d.continent, d."location", d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date)as countingpeoplevaccinated
from "covid-deaths" d
join "covid-vaccinations" v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2,3;


select d.continent, d."location", d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date)as countingpeoplevaccinated,
---(countingpeoplevaccinated/population)*100
from "covid-deaths" d
join "covid-vaccinations" v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2,3;

--USE CTE

with popvsvac (continent, location, date, population, new_vaccinations, countingpeoplevaccinated)
as
(
select d.continent, d."location", d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date)as countingpeoplevaccinated
--, (countingpeoplevaccinated/population)*100
from "covid-deaths" d
join "covid-vaccinations" v
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3;
)
select *, (countingpeoplevaccinated/population)*100 as percentagevac
from popvsvac

---TEMP TABLE

drop table if exists percentagepopulationvaccinated
Create temp table if not exists percentagepopulationvaccinated as 
(
continent varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccinations numeric,
countingpeoplevaccinated numeric
)

insert into percentagepopulationvaccinated
select d.continent, d."location", d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date)as countingpeoplevaccinated
--, (countingpeoplevaccinated/population)*100
from "covid-deaths" d
join "covid-vaccinations" v
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3
select *, (countingpeoplevaccinated/population)*100 as percentagevac
from percentagepopulationvaccinated;

-- CREATING VIEW FOR VISUALIZATION --
create view populationvaccinated as
select "date", sum("new_cases")--, "total_cases", "total_deaths" ,("total_deaths"/"total_cases")*100 as "death_percentA" 
from "covid-deaths"
--where location like '%Africa%'
where "continent" is not NULL
group by "date"
order by 1,2
limit 200;





