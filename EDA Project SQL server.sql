

select * from CovidDeaths;

-- Total Cases vs Total Deaths

select location,date,total_cases, total_deaths, (total_deaths/total_cases) * 100 as Deathpercentage
from CovidDeaths
where location like 'India'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population

select location,population, max(total_cases) as high_infected,  max((total_cases/population)) * 100 as Population_infected
from CovidDeaths
group by location, population
order by Population_infected desc;

-- Countries with Highest Death Count per Population

select location, Max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- contintents with the highest death count per population

select continent, Max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

select sum(new_cases) as newcases, sum(cast(new_deaths as int)) as newdeaths, sum(new_cases)/sum(cast(new_deaths as int)) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2;

-- Total Population vs Vaccinations

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast (cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) RollingVaccination
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

with PopulationVacc (continent, location, date, population, new_vaccinations, RollingVaccination)
as(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast (cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) RollingVaccination
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)
select *, (RollingVaccination/population) * 100
from PopulationVacc;

-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #PercentPopulationVaccn
create table #PercentPopulationVaccn(
	continent nvarchar(250),
	location nvarchar(250),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingVaccination numeric
)

insert into #PercentPopulationVaccn
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast (cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) RollingVaccination
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
--where cd.continent is not null

select *, (RollingVaccination/population) * 100
from #PercentPopulationVaccn


-- Creating Views to store data 
	
create view PercentPopulationVaccn as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast (cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) RollingVaccination
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
--where cd.continent is not null

select * from PercentPopulationVaccn;


create view totaldeathspercent as
select sum(new_cases) as newcases, sum(cast(new_deaths as int)) as newdeaths, sum(new_cases)/sum(cast(new_deaths as int)) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
--order by 1,2

select * from totaldeathspercent;

