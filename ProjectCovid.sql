--- selecting the column that we are working on
select *
from CovidDeath
where location like '%United States%'
order by 1,2

--- Looking total cases vs total deaths as Percentage 

select location, date, total_cases, total_deaths,CONVERT(float,total_deaths)/CONVERT(float, total_cases) * 100 as DeathPercentage
from CovidDeath
where location like '%Bangladesh%' 
order by 1,2


-- Looking at Total Cases vs Population
-- Population percentage those got affected

select location, date,population, total_cases,CONVERT(float,total_cases)/population * 100 as PercentPopulation
from CovidDeath
where location like '%Bangladesh%' 
order by 1,2

-- Countries with highest infection rate to population

select location,population, MAX(total_cases) as HighestInfection,MAX(CONVERT(float,total_cases)/population) * 100 as PercentPopulation
from CovidDeath
--where location like '%Bangladesh%' 
group by location,population
order by PercentPopulation desc



-- Countries with the highest death percentage

select location, MAX(cast(total_deaths as int)) as HighestDeath,MAX(CONVERT(float,total_deaths)/population) * 100 as DeathPercentPopulation
from CovidDeath
--where location like '%Bangladesh%' 
where continent is not null
group by location
order by DeathPercentPopulation desc


-- By continent 

select continent, MAX(cast(total_deaths as int)) as HighestDeath,MAX(CONVERT(float,total_deaths)/population) * 100 as DeathPercentPopulation
from CovidDeath
--where location like '%Bangladesh%' 
where continent is not null
group by continent
order by HighestDeath desc

-- Global Numbers(death and total infection per day)

select date, SUM(cast(new_cases as int)) as TotalNewCase,SUM(cast(new_deaths as int)) as GlobalDeath
from CovidDeath
where continent is not null
group by date
order by 1


-- Looking at Total Population vs Vaccination

SELECT top(10000) cvd.date, cvd.continent, cvd.location, population, new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by cvd.location) as totalVaccination
FROM CovidDeath cvd
	join CovidVaccinaiton cvv
	on cvd.date = cvv.date
	and cvd.location = cvv.location
where cvd.continent is not null
order by 3,2

-- Using CTE
-- Looking at the percentage of vaccination
With PopvsVac (date, continent, location, population, new_vaccinations, totalVaccination)
as
(
SELECT top(10000) cvd.date, cvd.continent, cvd.location, population, new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by cvd.location) as totalVaccination
FROM CovidDeath cvd
	join CovidVaccinaiton cvv
	on cvd.date = cvv.date
	and cvd.location = cvv.location
where cvd.continent is not null
order by 3,2
)
select *, (totalVaccination / population) * 100 as VaccinatedPercent
from PopvsVac

-- Temp Table 
--DROP Table if exist #PercentPopVaccinated
--create Table #PercentPopVaccinated
--(
--Date datetime,
--continent nvarchar(50),
--Location nvarchar(50),
--population numeric,
--New_vaccination numeric,
--TotalVaccination numeric
--)

Insert Into #PercentPopVaccinated
SELECT top(10000) cvd.date, cvd.continent, cvd.location, population, new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by cvd.location) as totalVaccination
FROM CovidDeath cvd
	join CovidVaccinaiton cvv
	on cvd.date = cvv.date
	and cvd.location = cvv.location
where cvd.continent is not null
order by 3,2

select *, (TotalVaccination / population) * 100 as VaccinatedPercent
from #PercentPopVaccinated

-- Creating View to store data for later Visualizations

create view PercentPopVaccinated as
SELECT top(10000) cvd.date, cvd.continent, cvd.location, population, new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by cvd.location) as totalVaccination
FROM CovidDeath cvd
	join CovidVaccinaiton cvv
	on cvd.date = cvv.date
	and cvd.location = cvv.location
where cvd.continent is not null
order by 3,2

select *
from PercentPopVaccinated

-- that's for today