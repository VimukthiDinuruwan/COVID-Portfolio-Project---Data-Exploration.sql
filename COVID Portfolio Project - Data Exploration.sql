/* =====================================================
   COVID-19 Data Exploration Project
   Author: Vimukthi Dinuruwan
   Skills: Joins, CTEs, Window Functions, Aggregates,
           Temp Tables, Views, Data Type Conversion
   ===================================================== */

---------------------------------------------------------
-- SECTION 1: Data Cleaning & Setup
---------------------------------------------------------

-- Preview the dataset (CovidDeaths)
SELECT TOP 10 *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Preview the dataset (CovidVaccinations)
SELECT TOP 10 *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY location, date;


---------------------------------------------------------
-- SECTION 2: Case Fatality Analysis
-- Goal: Likelihood of dying if you contract COVID
---------------------------------------------------------

SELECT location,
       date,
       total_cases,
       total_deaths,
       (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
  AND total_cases > 0
ORDER BY location, date;

-- Insight: This gives % chance of death if infected, varying by country.


---------------------------------------------------------
-- SECTION 3: Infection Rate Analysis
-- Goal: % of population infected
---------------------------------------------------------

SELECT location,
       date,
       population,
       total_cases,
       (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;


---------------------------------------------------------
-- SECTION 4: Highest Infection Rates by Country
---------------------------------------------------------

SELECT location,
       population,
       MAX(total_cases) AS HighestInfectionCount,
       MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Insight: Identifies countries where COVID spread the most relative to population.


---------------------------------------------------------
-- SECTION 5: Highest Death Counts by Country
---------------------------------------------------------

SELECT location,
       MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Insight: Shows absolute death toll by country.


---------------------------------------------------------
-- SECTION 6: Continent-Level Analysis
---------------------------------------------------------

SELECT continent,
       MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Insight: Aggregates deaths at continent level.


---------------------------------------------------------
-- SECTION 7: Global Numbers
---------------------------------------------------------

SELECT SUM(new_cases) AS GlobalCases,
       SUM(CAST(new_deaths AS INT)) AS GlobalDeaths,
       SUM(CAST(new_deaths AS INT)) * 100.0 / SUM(new_cases) AS GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

-- Insight: Shows global case fatality rate across all countries.


---------------------------------------------------------
-- SECTION 8: Vaccination Analysis (Using CTE)
---------------------------------------------------------

WITH PopVsVac AS (
    SELECT dea.continent,
           dea.location,
           dea.date,
           dea.population,
           vac.new_vaccinations,
           SUM(CAST(vac.new_vaccinations AS BIGINT)) 
                OVER (PARTITION BY dea.location ORDER BY dea.date) AS CumulativeVaccinations
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
         ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *,
       (CumulativeVaccinations/population)*100 AS PercentPopulationVaccinated
FROM PopVsVac;

-- Insight: Tracks progress of vaccinations as % of population.


---------------------------------------------------------
-- SECTION 9: Create a View (for BI/Visualization)
---------------------------------------------------------

CREATE VIEW PercentPopulationInfected AS
SELECT location,
       date,
       total_cases,
       population,
       (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

-- Now we can easily query PercentPopulationInfected in Power BI/Tableau.


---------------------------------------------------------
-- SECTION 10: Advanced Example - Cumulative Cases
---------------------------------------------------------

SELECT location,
       date,
       SUM(new_cases) OVER (PARTITION BY location ORDER BY date) AS CumulativeCases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

-- Insight: Shows cumulative case growth by country over time.

