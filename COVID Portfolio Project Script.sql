SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- Total cases vs Total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
AND continent is NOT NULL
ORDER BY 1,2

--Total cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
ORDER BY 1,2

-- Countries with highest infection rate compaed to population population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Countries with highest death count per population

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Countries with highest death count per population

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continents with highest death count per population

SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)), SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
WHERE continent is NOT NULL
ORDER BY 1,2


SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Join Death and vaccination table with location & date

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM PopvsVac

--TEMP Table

DROP table if exists #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
FROM #PercentPopulationVaccinated


-- Create view to store data for visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated