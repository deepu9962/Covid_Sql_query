--calculation of likelihood of dying in a covid stricken country
--for example in india
select location, date, total_deaths, population, (total_deaths/total_cases)*100 as Deathpercent
from CovidDeaths
where location='india'

--looking at total cases vs population
--shows what percenatge of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as Death_toll
from CovidDeaths
--where location like '%states'
order by 1,2

---LOOKING AT COUNTRIES WITH highest infection rate compared to population

select location, population, MAX(total_cases) AS Highest_infected_count,  MAX((total_cases/population)*100) as Populated_infected
from CovidDeaths
group by location, population
order by Populated_infected desc


--showing continents with highest death counts
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc

--Global numbers
select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Deathpercent
from CovidDeaths
where continent is not null
group by date
order by 1,2

--total covid cases around the worlds
select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Deathpercent
from CovidDeaths
where continent is not null
order by 1,2

--looking at total population vs vaccinations 
select cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations, SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION by cd.location ORDER BY cd.location, cd.date) as Rolling_People_Populated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3

--USE CTE

WITH PopvsVac(Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated) as
( select cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations, SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION by cd.location ORDER BY cd.location, cd.date) as Rolling_People_Populated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
)
select * , (RollingPeopleVaccinated/population)*100 from PopvsVac

--Temp Table

DROP TABLE if exists #PercentPopulationVaccination
Create Table #PercentPopulationVaccination(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccination
select cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations, SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION by cd.location ORDER BY cd.location, cd.date) as Rolling_People_Populated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date


select * , (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccination

--Creating View for Visualization

Create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations, SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION by cd.location ORDER BY cd.location, cd.date) as Rolling_People_Populated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null

Select * from PercentPopulationVaccinated
