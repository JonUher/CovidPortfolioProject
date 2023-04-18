--Calculates the percentage of total_deaths out of total_cases

--SELECT
--location, date, total_cases, total_deaths, (total_deaths/CAST(total_cases as float))*100 as 'MortalityRate'
--FROM
--CovidDeaths
--ORDER BY
--location, date

--Calculates the percentage of the total_cases out of population

--SELECT
--location, MAX(CAST(total_cases as int)) as HighestInfectionCount, population, MAX((total_cases/population)*100) as HighestInfectionRate
--FROM
--CovidDeaths
--WHERE 
--continent is not null
--GROUP BY
--location, population
--ORDER BY
--HighestInfectionRate desc

--SELECT
--continent, location, MAX(CAST(total_cases as int)) as HighestInfectionCount, population
--FROM
--CovidDeaths
--WHERE
--continent = 'north america'
--GROUP BY
--continent, location, population 
--ORDER BY
--population desc

-- Returns the total_cases as a percentage of the population for regions and income levels

--SELECT
--continent, location, population, MAX(CAST(total_cases as int)) as MaxTotalCases, MAX((CAST(total_cases as int)/population)*100) as InfectionRate
--FROM
--CovidDeaths
--WHERE
--continent is null
--GROUP BY
--continent, location, population
--ORDER BY
--InfectionRate desc


--Returns Global total_cases by date

--SELECT
--date,SUM(CAST(total_cases as bigint)) as GlobalTotalCases, SUM(population) as GlobalPopulation, (SUM(CAST(total_cases as bigint))/SUM(population))*100 as GlobalInfectionRate
--FROM
--CovidDeaths
--WHERE
--continent is not null
--GROUP BY
--date
--ORDER BY
--date


--Shows the rolling total of vaccinations in each country

--SELECT
--dea.continent, dea.location, dea.date, dea.population, test.new_vaccinations as NewVaccinations, SUM(CAST(test.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
--FROM
--CovidDeaths dea
--join
--CovidTests test 
--on 
--dea.location = test.location
--and
--dea.date = test.date
--WHERE
--dea.continent is not null
--GROUP BY
--dea.continent, dea.location, dea.date, dea.population, test.new_vaccinations
--ORDER BY
--dea.location, dea.date




--WITH PopvsTest (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated,people_vaccinated)
--as
--(
--SELECT
--dea.continent, dea.location, dea.date, dea.population, test.new_vaccinations as NewVaccinations, SUM(CAST(test.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated, people_vaccinated
--FROM
--CovidDeaths dea
--join
--CovidTests test 
--on 
--dea.location = test.location
--and
--dea.date = test.date
--WHERE
--dea.continent is not null
--GROUP BY
--dea.continent, dea.location, dea.date, dea.population, test.new_vaccinations, people_vaccinated
--)
--SELECT
--*, (RollingPeopleVaccinated/Population)*100 as RollingPercentVaccinated
--FROM
--PopvsTest
--WHERE
--Location = 'united states' and people_vaccinated is not null
--ORDER BY
--Location, Date


--Creates a temp table

--DROP TABLE if exists #PercentPopulationVaccinated
--CREATE TABLE #PercentPopulationVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date date,
--Population bigint,
--New_vaccinations bigint,
--RollingPeopleVaccinated bigint,
--)
--INSERT INTO #PercentPopulationVaccinated
--SELECT
--dea.continent, dea.location, dea.date, dea.population, test.new_vaccinations as NewVaccinations, SUM(CAST(test.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
--FROM
--CovidPortfolioProject..CovidDeaths dea
--join
--CovidPortfolioProject..CovidTests test 
--on 
--dea.location = test.location
--and
--dea.date = test.date
--WHERE
--dea.continent is not null
--GROUP BY
--dea.continent, dea.location, dea.date, dea.population, test.new_vaccinations


--Creating a view for visulaization

USE CovidPortfolioProject
GO

CREATE VIEW PercentPopulationVaccinated as 
SELECT
dea.continent, dea.location, dea.date, dea.population, test.new_vaccinations as NewVaccinations, SUM(CAST(test.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingPeopleVaccinated
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

SELECT
*
FROM
PercentPopulationVaccinated