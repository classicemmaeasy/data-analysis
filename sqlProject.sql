select* from potfolio..covidvaccination

--select*
--from potfolio..covidvaccination
--where location='Nigeria'
--order by 3,4

--selecting data to be use
select Location,date,total_cases,new_cases,total_deaths,population
from potfolio..coviddeath
order by 1,2

----looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from potfolio..coviddeath
where continent is not null
and location like '%Nigeria%'
order by 1,2

--looking at Total cases vs population
--what percentage of population has contracted covid
select Location,date,total_cases,population,(total_cases/population)*100 as Population_Percentage
from potfolio..coviddeath
 where continent is not null
and location like '%Nigeria%'
order by 1,2

 --looking at the highest infection rate compared to the population
 select location,population,max(total_cases) as highest_cases,max(total_cases/population)*100 as percentagePopulation
 from potfolio..coviddeath
  where continent is not null
 --where location like '%Nigeria%'
 group by location,population
 order by percentagePopulation desc


--countries with the highest death
 select location,max(total_deaths) as total_deaths_count
 from potfolio..coviddeath
  where continent is not null
 group by location
 order by total_deaths_count desc

 --breaking it down by continent(highest death in each continent)
 select continent,max(total_deaths) as total_deaths_count
 from potfolio..coviddeath
  where continent is not null
 group by continent
 order by total_deaths_count desc

 --select* 
 --from potfolio..coviddeath
 --where continent is not null


--GLOBAL NUMBERS

select sum(new_cases) as total_new_cases,sum(new_deaths) as total_new_deaths,sum(new_deaths)/sum(new_cases)*100 as percentage_death
from potfolio..coviddeath
where continent is not null
--and location like '%Nigeria%'
--GROUP BY date
order by 1,2

--looking at total population vs Vacccination base on location and date

select d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(cast(v.new_vaccinations as float)) 
over(partition by d.location order by d.location,d.date )as RollingPeopleVaccination
from potfolio..coviddeath  d
join potfolio..covidvaccination v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
order by 2,3;
	 
--Using CTE
 with PopVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccination)
	as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(cast(v.new_vaccinations as float)) 
over(partition by d.location order by d.location,d.date )as RollingPeopleVaccination
from potfolio..coviddeath  d
join potfolio..covidvaccination v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
--order by 2,3 
 )
 select *, (RollingPeopleVaccination/population)*100 as Pecentage_vaccination
 from PopVac
 



 --#TempTable

DROP TABLE IF EXISTS  #Percentage_Pop_Vac
create table #Percentage_Pop_Vac(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations float,
RollingPeopleVaccination numeric
)

insert into #Percentage_Pop_Vac
select d.continent,d.location,d.date,d.population, v.new_vaccinations,SUM(cast(v.new_vaccinations as float)) 
over(partition by d.location order by d.location,d.date )as RollingPeopleVaccination
from potfolio..coviddeath  d
join potfolio..covidvaccination v
	on d.location=v.location
	and d.date=v.date
--where d.continent is not null
--order by 2,3 

-- percentage of people vaccinated
 select *, (RollingPeopleVaccination/population)*100  as Perc_Population_Vacc
 from #Percentage_Pop_Vac
 order by  Perc_Population_Vacc desc
 


create view Percentage_Pop_Vac as
select d.continent,d.location,d.date,d.population, v.new_vaccinations,SUM(cast(v.new_vaccinations as float)) 
over(partition by d.location order by d.location,d.date )as RollingPeopleVaccination
from potfolio..coviddeath  d
join potfolio..covidvaccination v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
--order by 2,3 
 
select* 
from Percentage_Pop_Vac