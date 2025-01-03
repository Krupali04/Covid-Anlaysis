use PortfolioProject;

DESCRIBE coviddeaths;

-- Updating the location

UPDATE coviddeaths
SET continent = NULL
WHERE location IN ('Africa', 'Europe','South America','North America','Oceania','Asia','Antartica','European Union');

SELECT * FROM coviddeaths;

SELECT location,date,total_cases,new_cases
FROM coviddeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2;

-- Total Cases VS Total Deaths

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM coviddeaths
WHERE location LIKE '%States%'
AND Continent IS NOT NULL
ORDER BY 1,2;

-- Total Cases VS Population
-- Shows what percentage of Population got Covid

SELECT location,date,Population,total_cases, (total_cases/Population)*100 AS Population_Percentage
FROM coviddeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2;

-- Countries with highest Infected Rate compared to Population
 
SELECT location,Population,MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/Population))*100 AS PercentPopulationInfected
FROM coviddeaths
WHERE Continent IS NOT NULL
GROUP BY location,Population
ORDER BY PercentPopulationInfected DESC;

-- Countries with Highest Death Count Per Population

SELECT location,MAX(CAST(total_deaths AS SIGNED)) AS HighestDeathCount
FROM coviddeaths
WHERE Continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Continent with Highest Death Count Per Population

SELECT continent,MAX(CAST(total_deaths AS SIGNED)) AS HighestDeathCount
FROM coviddeaths
WHERE Continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

-- GLOBAL NUMBERS

SELECT Date, SUM(new_cases) AS Total_NewCases, SUM(new_deaths) AS Total_NewDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY Total_NewCases DESC;

SELECT SUM(new_cases) AS Total_NewCases, SUM(new_deaths) AS Total_NewDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY Total_NewCases DESC;

-- JOIN

SELECT *
FROM coviddeaths dea
JOIN covidvaccination vac
ON dea.location=vac.location
AND dea.date =vac.date;

-- Total Population vs Total Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CONVERT(vac.new_vaccinations,SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccination vac
     ON dea.location=vac.location
     AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location,dea.date;

-- Percentage of People Vaccinated
-- CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CONVERT(vac.new_vaccinations,SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccination vac
     ON dea.location=vac.location
     AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location,dea.date
)

SELECT *,(RollingPeopleVaccinated/Population)*100 As PercentPopulationVaccinated
FROM PopvsVac;

-- Temp Table

DROP  TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date date,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CONVERT(vac.new_vaccinations,SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccination vac
     ON dea.location=vac.location
     AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location,dea.date;

SELECT *,(RollingPeopleVaccinated/Population)*100 As PercentPopulationVaccinated
FROM PercentPopulationVaccinated;

-- Creating Views for later Visualizations
-- View for Total Populaton Vaccinated 

CREATE VIEW PopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CONVERT(vac.new_vaccinations,SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccination vac
     ON dea.location=vac.location
     AND dea.date =vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location,dea.date;

SELECT * FROM PopulationVaccinated;

-- View for Global Numbers

CREATE VIEW GlobalNumbers AS
SELECT SUM(new_cases) AS Total_NewCases, SUM(new_deaths) AS Total_NewDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY Total_NewCases DESC;

SELECT * FROM GlobalNumbers;

-- View for Highest Death Count by Continent

CREATE VIEW DeathCountByContinent AS
SELECT continent,MAX(CAST(total_deaths AS SIGNED)) AS HighestDeathCount
FROM coviddeaths
WHERE Continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

SELECT * FROM DeathCountByContinent;