USE portfolioProject

/*SELECT *
FROM covidVax
ORDER BY 3,4;


SELECT *
FROM covidDeaths
ORDER BY 3,4;
*/

--Select data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covidDeaths
ORDER BY 1,2;

--View of Total Cases vs. Total Deaths
--Shows likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM covidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

--View of Total Cases vs. Population
--Shows Percent of Population that has Contracted COVID-19

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercent
FROM covidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

--Looking at countries with highest infection rates compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopInfected
FROM covidDeaths
GROUP BY location, population
ORDER BY PercentPopInfected DESC;

--Showing countries with highest death total

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeaths
FROM covidDeaths
WHERE continent IS NOT null
GROUP BY location
ORDER BY TotalDeaths DESC;

--Breakdown by CONTINENT 
SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeaths
FROM covidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeaths DESC;

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeaths
FROM covidDeaths
WHERE continent IS null 
GROUP BY location
ORDER BY TotalDeaths DESC;

--Showing continents with highest death count

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM covidDeaths
WHERE continent IS NOT null;

--Total vaccination vs. population
--USE CTE

WITH PopVsVax (continent, location, date, population, new_vaccinations, VaxCountByDate)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CONVERT(BigInt, vax.new_vaccinations)) 
	OVER (PARTITION BY dea.location
	ORDER BY dea.location, dea.date) AS VaxCountByDate
FROM covidDeaths dea
JOIN covidVax vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3;
)

SELECT *, (VaxCountByDate/population)*100
FROM PopVsVax

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaxCountByDate numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CONVERT(BigInt, vax.new_vaccinations)) 
	OVER (PARTITION BY dea.location
	ORDER BY dea.location, dea.date) AS VaxCountByDate
FROM covidDeaths dea
JOIN covidVax vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3;

SELECT *, (VaxCountByDate/population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CONVERT(BigInt, vax.new_vaccinations)) 
	OVER (PARTITION BY dea.location
	ORDER BY dea.location, dea.date) AS VaxCountByDate
FROM covidDeaths dea
JOIN covidVax vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT null
--ORDER BY 2,3;
