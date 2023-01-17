SELECT * 
FROM [Portfolio Project]..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT * 
--FROM [Portfolio Project]..Covid_Vaccination
--ORDER BY 3,4

--SELECT USING DATA

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..Covid_Deaths
ORDER BY 1,2;

-- LOOKING AT TOTAL CASES VS TOTAL DEATH
-- Shows likelihood of dying if contract covid in a certain country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percent_population_infected
FROM [Portfolio Project]..Covid_Deaths
WHERE location LIKE '%States%'
ORDER BY 1,2;

--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULAITON GOT COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 AS death_percentage 
FROM [Portfolio Project]..Covid_Deaths
WHERE location LIKE '%States%'
ORDER BY 1,2;

--LOOKING AT COUNTRY WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases)AS Highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM [Portfolio Project]..Covid_Deaths
--WHERE location LIKE '%States%'
GROUP BY location, population
ORDER BY percent_population_infected DESC;


--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(total_deaths) AS total_death_count
FROM [Portfolio Project]..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;


--BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(total_deaths) AS total_death_count
FROM [Portfolio Project]..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;


--SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION 
SELECT location, MAX(total_deaths) AS total_death_count
FROM [Portfolio Project]..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

--GLOBAL NUMBERS PER DAY 
SELECT date, SUM(new_cases) AS total_cases ,SUM(new_deaths) AS total_deaths,(SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM [Portfolio Project]..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

--GLOBAL NUMBERS IN TOTAL
SELECT SUM(new_cases) AS total_cases ,SUM(new_deaths) AS total_deaths,(SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM [Portfolio Project]..Covid_Deaths
WHERE continent IS NOT NULL



--LOOKING AT TOTAL POPULATION VS VACCINATION
--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_accumulation_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS rolling_accumulation_people_vaccinated
FROM [Portfolio Project]..Covid_Deaths dea
JOIN [Portfolio Project]..Covid_Vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date  
	WHERE dea.continent IS NOT NULL)
	SELECT *, (rolling_accumulation_people_vaccinated/population)*100
	FROM PopvsVac

-- TEMP TABLE #
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(50),
location nvarchar(50),
date datetime2,
population float,
new_vaccinations float, 
rolling_accumulation_people_vaccinated float,
)
SELECT * FROM #PercentPopulationVaccinated

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS rolling_accumulation_people_vaccinated
FROM [Portfolio Project]..Covid_Deaths dea
JOIN [Portfolio Project]..Covid_Vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date  
--WHERE dea.continent IS NOT NULL)

SELECT *, (rolling_accumulation_people_vaccinated/population)*100
	FROM #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISULIZAITON
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS rolling_accumulation_people_vaccinated
FROM [Portfolio Project]..Covid_Deaths dea
JOIN [Portfolio Project]..Covid_Vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date  
WHERE dea.continent IS NOT NULL
 
SELECT * FROM PercentPopulationVaccinated



