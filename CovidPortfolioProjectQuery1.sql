--Creates a view showing the mortality rate by country

USE CovidPortfolioProject
GO
CREATE VIEW MortalityRate as
SELECT
Location, CAST(date as date) as Date, total_cases as TotalCases, total_deaths as TotalDeaths, (total_deaths/CAST(total_cases as float))*100 as MortalityRate
FROM
CovidDeaths

--Creates a view showing the infection rate by country

USE CovidPortfolioProject
GO
CREATE VIEW InfectionRate as 
WITH InfRate (Continent, location, Population, HighestInfectionCount)
as
(
SELECT
Continent, Location, Population, MAX(CAST(total_cases as int)) as HighestInfectionCount
FROM
CovidPortfolioProject..CovidDeaths dea
WHERE 
continent is not null
GROUP BY
continent, location, population
)
SELECT
*,(HighestInfectionCount/Population)*100 as HighestInfectionRate
FROM
InfRate
WHERE
HighestInfectionCount is not null


--Creates a view showing the infection rate by region or income level

USE CovidPortfolioProject
GO
CREATE VIEW InfectionRatebyClassification as
SELECT
continent, location, population, MAX(CAST(total_cases as int)) as MaxTotalCases, MAX((CAST(total_cases as int)/population)*100) as InfectionRate
FROM
CovidDeaths
WHERE
continent is null
GROUP BY
continent, location, population


--Returns the global infection rates ordered by date

SELECT
date, SUM(population) as GlobalPopulation, SUM(CAST(total_cases as bigint)) as GlobalTotalCases, (SUM(CAST(total_cases as bigint))/SUM(population))*100 as GlobalInfectionRate
FROM
CovidDeaths
WHERE
continent is not null
GROUP BY
date
ORDER BY
date


/*Creates a temp table of the rolling vaccination count by country
This is a flawed metric because new_vaccinations includes things beyond the first shot leading to rolling counts that exceed population*/

DROP TABLE if exists #VaccinationRate
CREATE TABLE #VaccinationRate
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population bigint,
New_vaccinations bigint,
RollingPeopleVaccinated bigint,
)
INSERT INTO #VaccinationRate
SELECT
dea.continent, dea.location, dea.date, dea.population, test.new_vaccinations as NewVaccinations,
SUM(CAST(test.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
FROM
CovidPortfolioProject..CovidDeaths dea
join
CovidPortfolioProject..CovidTests test 
on 
dea.location = test.location
and
dea.date = test.date
WHERE
dea.continent is not null
GROUP BY
dea.continent, dea.location, dea.date, dea.population, test.new_vaccinations


/*Creates a view of the vaccination rate by country by date
This uses the more reliable people_vaccinated to resolve issues of inaccuarate rolling counts*/

USE CovidPortfolioProject
GO
CREATE VIEW VaccinationRate as
SELECT
dea.continent, dea.location, dea.date, dea.population, test.people_vaccinated, (CAST(test.people_vaccinated as bigint)/dea.population)*100 as VaccinationRate
FROM
CovidPortfolioProject..CovidDeaths dea
join
CovidPortfolioProject..CovidTests test 
on 
dea.location = test.location
and
dea.date = test.date
WHERE
dea.continent is not null
GROUP BY
dea.continent, dea.location, dea.date, dea.population,test.people_vaccinated
--ORDER BY
--location, date