SELECT *
FROM Project1.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM Project1.dbo.CovidVaccinations
--ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project1.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


--Looking at Total Cases vs. Total Deaths
--Shows the likelihood of dying if you contract Covid in a specified country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Project1.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


--Looking at the Total Cases vs. Population
--Shows what percentage of population contracted Covid at a given time

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM Project1.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS MaxInfectedPercentage
FROM Project1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY MaxInfectedPercentage DESC;


--Showing countries with the highest death count

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Project1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


--Breaking things down by continent
--Showing continents with the highest death counts
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Project1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


 --Global Numbers
 --Total number of cases and deaths per day

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM Project1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--World Total number of cases and deaths per day

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM Project1.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking at total population vs. vaccinations
--Using CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinations 
FROM Project1.dbo.CovidDeaths dea
JOIN Project1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
)
SELECT *, (CumulativeVaccinations/Population)*100
FROM PopvsVac 



--Using Temp table

DROP TABLE IF EXISTS
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
CumulativeVaccinations NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinations 
FROM Project1.dbo.CovidDeaths dea
JOIN Project1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (CumulativeVaccinations/Population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinations 
FROM Project1.dbo.CovidDeaths dea
JOIN Project1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL