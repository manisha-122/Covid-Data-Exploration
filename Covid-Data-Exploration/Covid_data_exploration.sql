create database COVID_PROJECT;
use COVID_PROJECT;

select * from covid_project.coviddeaths 
where continent is not null
order by 3,4 ;

select location, date, total_cases, new_cases, total_deaths, population
from covid_project.coviddeaths
where continent is not null 
order by 1,2;

-- Cases Vs Deaths

select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_project.CovidDeaths
where continent is not null 
order by 1,2;

-- Cases Vs Population
select Location, date,population, total_cases, (total_cases/population)*100 as PopulationInfectedPercent
from covid_project.CovidDeaths
where continent is not null 
order by PopulationInfectedPercent desc;

-- Countries with highest  infected rate
select Location,population, max(total_cases) as HighestInfected, max((total_cases/population))*100 as PopulationInfectedPercent
from covid_project.CovidDeaths
group by location
order by PopulationInfectedPercent desc;

-- Countries with highest death count
select Location, max(cast(Total_deaths as signed )) as TotalDeathCount
from covid_project.CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;

-- Contintents with the highest death count

select Continent, max(cast(Total_deaths as signed)) as TotalDeathCount
from covid_project.CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- Percentage of Population received vaccine
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as signed)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From covid_project.CovidDeaths d
Join covid_project.CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
order by 2,3;

-- Using Temp Table to perform Calculation on Partition By in previous query

 DROP Table if exists PercentPopulationVaccinated ;
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated 
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.New_vaccinations as signed)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From covid_project.CovidDeaths d
Join covid_project.CovidVaccinations v
	On d.location = v.location
	and d.date = v.date;


Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;




-- Creating View to store data for later visualizations

create view PercentPopulationVaccinatedView as
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.New_vaccinations as signed)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From covid_project.CovidDeaths d
Join covid_project.CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 