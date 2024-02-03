 
SELECT*
FROM [Portfolio Project - Covid Data]..CovidVaccinations
ORDER BY Location, Date 

--Select Data to be used for this analysis

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project - Covid Data]..CovidDeaths
ORDER BY location, date

-- Total Cases vs Total Deaths
-- Shows the likelihood of Dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project - Covid Data]..CovidDeaths
WHERE location = 'Nigeria' AND continent IS NOT NULL
ORDER BY location, date 

-- Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM [Portfolio Project - Covid Data]..CovidDeaths
WHERE location = 'Nigeria'
ORDER BY location, date 
 
-- Countries with the highest infection rate compared to their total population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project - Covid Data]..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Countries with the Higehest Death Count per Population

SELECT location, population, MAX(total_deaths) AS TotalDeathCount, MAX((total_deaths/population))*100 AS PercentPopulationDeath
FROM [Portfolio Project - Covid Data]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count

SELECT continent, MAX(total_deaths) AS TotalDeathCount, MAX((total_deaths/population))*100 AS PercentPopulationDeath
FROM [Portfolio Project - Covid Data]..CovidDeaths
WHERE continent IS not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT continent, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths,
SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project - Covid Data]..[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY Continent, TotalCases

-- Total Population vs Vaccinations

SELECT*
FROM [Portfolio Project - Covid Data]..[CovidVaccinations]

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations
,SUM(vaccinations.new_vaccinations) OVER (PARTITION BY Deaths.Location ORDER BY Deaths.location, Deaths.Date) AS RollingPeopleVaccinated
FROM [Portfolio Project - Covid Data]..[CovidDeaths] AS Deaths
JOIN [Portfolio Project - Covid Data]..[CovidVaccinations] AS Vaccinations
ON Deaths.location = Vaccinations.location
AND Deaths.date = Vaccinations.date
WHERE Deaths.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE
WITH PopulationVsVaccination (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations
,SUM(vaccinations.new_vaccinations) OVER (PARTITION BY Deaths.Location ORDER BY Deaths.location, Deaths.Date) AS RollingPeopleVaccinated
FROM [Portfolio Project - Covid Data]..[CovidDeaths] AS Deaths
JOIN [Portfolio Project - Covid Data]..[CovidVaccinations] AS Vaccinations
ON Deaths.location = Vaccinations.location
AND Deaths.date = Vaccinations.date
WHERE Deaths.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100 AS Percent_Population_Vaccinated
FROM PopulationVsVaccination

--USE TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population FLOAT,
New_Vaccinations FLOAT,
RollingPeopleVaccinated FLOAT
)

INSERT INTO #PercentPopulationVaccinated
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations
,SUM(vaccinations.new_vaccinations) OVER (PARTITION BY Deaths.Location ORDER BY Deaths.location, Deaths.Date) AS RollingPeopleVaccinated
FROM [Portfolio Project - Covid Data]..[CovidDeaths] AS Deaths
JOIN [Portfolio Project - Covid Data]..[CovidVaccinations] AS Vaccinations
ON Deaths.location = Vaccinations.location
AND Deaths.date = Vaccinations.date
--WHERE Deaths.continent IS NOT NULL
--ORDER BY 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100 AS Percent_Population_Vaccinated
FROM #PercentPopulationVaccinated

-- Creating View to Store Data for Later Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations
,SUM(vaccinations.new_vaccinations) OVER (PARTITION BY Deaths.Location ORDER BY Deaths.location, Deaths.Date) AS RollingPeopleVaccinated
FROM [Portfolio Project - Covid Data]..[CovidDeaths] AS Deaths
JOIN [Portfolio Project - Covid Data]..[CovidVaccinations] AS Vaccinations
ON Deaths.location = Vaccinations.location
AND Deaths.date = Vaccinations.date
WHERE Deaths.continent IS NOT NULL
--ORDER BY 2,3


SELECT*
FROM PercentPopulationVaccinated