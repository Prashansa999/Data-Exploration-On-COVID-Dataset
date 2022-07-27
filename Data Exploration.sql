
--SELECT DATA THAT WE ARE GOING TO START WITH 
Select location, date, total_cases, new_cases, total_deaths, population
From covidanalysis..COVID
Where continent is not null 
order by 1,2


--TOTAL CASES VS TOTAL DEATH
--SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
SELECT location, date, total_cases, CAST(total_deaths AS int), (total_cases/cast(total_deaths as int))*100 as deathpercentage
FROM covidanalysis..COVID
WHERE continent is not null
order by 1,2

--TOTAL CASES VS TOTAL POPULATION
--SHOWS WHAT PERCENTAGE OF PEOPLE ARE INFECTED BY COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM covidanalysis..COVID
WHERE continent is not null
order by 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) as HighestInfectionrate, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM covidanalysis..COVID
WHERE continent is not null
GROUP BY location, population 
order by PercentpopulationInfected desc

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM covidanalysis..COVID
WHERE continent is not null and total_deaths is not null
GROUP BY location
order by TotalDeathCount desc

--CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From covidanalysis..COVID
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
FROM covidanalysis..COVID
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--TOTAL POPULATION VS VACCINATION
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM covidanalysis..COVID dea
JOIN covidanalysis..VACCINATIONS vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location) as RollingPeopleVaccinated
FROM covidanalysis..COVID dea
JOIN covidanalysis..VACCINATIONS vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
Select *
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covidanalysis..COVID dea
JOIN covidanalysis..VACCINATIONS vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated









