SELECT *
FROM COVID_PROJECT..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM COVID_PROJECT..covid_deaths
ORDER BY 1,2 

-- Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM COVID_PROJECT..covid_deaths
WHERE location like '%states%'
ORDER BY 1,2 

-- Total cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, Population, total_cases, (total_deaths/Population)*100 AS Percent_Population_Infected
FROM COVID_PROJECT..covid_deaths
--WHERE location like '%states%'
ORDER BY 1,2

-- Country with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/Population))*100 AS Percent_Population_Infected
FROM COVID_PROJECT..covid_deaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY Percent_Population_Infected DESC

-- Showing Countries with Highest Death  Count per Population

SELECT Location, MAX(cast(total_deaths AS INT)) AS Total_Deaths_Count 
FROM COVID_PROJECT..covid_deaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY Total_Deaths_Count DESC

-- BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths AS INT)) AS Total_Deaths_Count 
FROM COVID_PROJECT..covid_deaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Deaths_Count DESC

-- Showing continents with the higest death count per Population

SELECT continent, MAX(cast(total_deaths AS INT)) AS Total_Deaths_Count 
FROM COVID_PROJECT..covid_deaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Deaths_Count DESC

--  GLOBAL NUMBERS

-- #1
SELECT date, SUM(new_cases) AS total_cases, 
			 SUM(CAST(new_deaths AS int)) AS total_deaths, 
			 SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM COVID_PROJECT..covid_deaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 

-- #2
SELECT SUM(new_cases) AS total_cases, 
	   SUM(CAST(new_deaths AS int)) AS total_deaths, 
	   SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM COVID_PROJECT..covid_deaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 


-- Total Population vs Vaccinations

SELECT dea.continent, 
       dea.location, 
	   dea.date, 
       dea.population, 
       vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY dea.Location,dea.date)
	   AS Rolling_People_Vaccinated--,(Rolling_People_Vaccinated/Population)*100
FROM COVID_PROJECT..covid_deaths dea
JOIN COVID_PROJECT..covid_vaccine vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
WITH Population_vs_Vaccinated (Continent, Location, Date, Population, New_Vacinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, 
       dea.location, 
	   dea.date, 
       dea.population, 
       vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY dea.Location,dea.date)
	   AS Rolling_People_Vaccinated--,(Rolling_People_Vaccinated/Population)*100
FROM COVID_PROJECT..covid_deaths dea
JOIN COVID_PROJECT..covid_vaccine vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM Population_vs_Vaccinated


-- TEMP TABLE

DROP TABLE if exists #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vacinations numeric,
Rolling_People_Vaccinated numeric,
)
INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent, 
       dea.location, 
	   dea.date, 
       dea.population, 
       vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY dea.Location,dea.date)
	   AS Rolling_People_Vaccinated--,(Rolling_People_Vaccinated/Population)*100
FROM COVID_PROJECT..covid_deaths dea
JOIN COVID_PROJECT..covid_vaccine vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM #Percent_Population_Vaccinated



-- Create View to store data for later visualizations 

CREATE VIEW Percent_Population_Vaccinated as
SELECT dea.continent, 
       dea.location, 
	   dea.date, 
       dea.population, 
       vac.new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.Location ORDER BY dea.Location,dea.date)
	   AS Rolling_People_Vaccinated--,(Rolling_People_Vaccinated/Population)*100
FROM COVID_PROJECT..covid_deaths dea
JOIN COVID_PROJECT..covid_vaccine vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM Percent_Population_Vaccinated