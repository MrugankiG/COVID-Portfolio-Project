SELECT * 
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
order by 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations$
WHERE continent is not null
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2



-- Total Cases Vs Total Deaths

SELECT location, date, total_cases, total_deaths, 
(CONVERT(float,total_deaths)/NULLIF(CONVERT(float, total_cases),0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'India' and continent is not null
ORDER BY 1,2



--Total Cases vs Population
-- Shows what percentage of population got COVID

SELECT location, date, population, total_cases, 
(CONVERT(float,total_cases)/population)*100 AS gotCovidPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'India' and continent is not null
ORDER BY 1,2



-- Countries with highest Infection Rate Compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, 
MAX((CONVERT(float,total_cases)/population))*100 AS gotCovidPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY gotCovidPercentage desc



-- Countries with the highest Death Count per population

SELECT Location, MAX(cast(total_deaths as int)) as totalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY totalDeathCount desc



--By Continent with the Highest Death Count per population

SELECT continent, MAX(cast(total_deaths as int)) as totalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeathCount desc



-- Global Numbers 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/nullif(SUM(New_Cases),0)*100 as deathPercentage 
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2



-- Joining CovidDeaths and CovidVaccinations table on 'location' and 'date'
SELECT *
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where continent is not null



--Looking at total Population VS count of people who got vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
	(Partition By dea.Location Order by dea.location, dea.Date) 
	as RollingCount_PeopleVaccinated
-- WE as of now cannot use "RollingCount_PeopleVaccinated" for mathematical operation, thus WE will use CTE or Temp_tables
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3



-- CTE(Common Table expressions)

With PopVsVac(Continent, Location, Date, Population, New_Vaccinations,  RollingCount_PeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
	(Partition By dea.Location Order by dea.location, dea.Date) 
	as RollingCount_PeopleVaccinated
-- WE as of now cannot use "RollingCount_PeopleVaccinated" for mathematical operation, thus WE will use CTE or Temp_tables
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)

Select *, (RollingCount_PeopleVaccinated/Population)*100 
FROM PopVsVac



--TEMP Table
DROP TABLE IF exists #percentPopulationVaccinated
CREATE TABLE #percentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #percentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
	(Partition By dea.Location Order by dea.location, dea.Date) 
	as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null


SELECT *, (RollingPeopleVaccinated/Population)*100
From #percentPopulationVaccinated




--Creating views to store data for Visualization

CREATE View percentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
	(Partition By dea.Location Order by dea.location, dea.Date) 
	as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null


Select *
From percentPopulationVaccinated

