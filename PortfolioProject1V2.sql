SELECT *
FROM PortfolioProject1..COVIDDeaths$
Where continent is not null
Order By 3,4

--SELECT *
--FROM PortfolioProject1..COVIDVaccinations$
--Order By 3,4

-- Select the Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..COVIDDeaths$
Order By 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1..COVIDDeaths$
Where location LIKE '%states%'
Order By 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject1..COVIDDeaths$
--Where location LIKE '%states%'
Order By 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject1..COVIDDeaths$
--Where location LIKE '%states%'
GROUP BY location, population
Order By PercentPopulationInfected DESC

-- Showing Countires with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject1..COVIDDeaths$
--Where location LIKE '%states%'
Where continent is not null
GROUP BY location
Order By TotalDeathCount DESC

-- LET's BREAK THINGS DOWN BY CONTINENT
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject1..COVIDDeaths$
--Where location LIKE '%states%'
Where continent is null
GROUP BY location
Order By TotalDeathCount DESC

-- LET's BREAK THINGS DOWN BY CONTINENT Version II

-- Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject1..COVIDDeaths$
--Where location LIKE '%states%'
Where continent is not null
GROUP BY continent
Order By TotalDeathCount DESC

-- Global Numbers by Date

SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject1..COVIDDeaths$
--Where location LIKE '%states%'
Where continent is not null
GROUP BY date
Order By 1,2

-- Global Totals

SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject1..COVIDDeaths$
--Where location LIKE '%states%'
Where continent is not null
Order By 1,2

-- Looking at Total Population vs Vaccinations

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(cast(VAC.new_vaccinations AS Int)) OVER (Partition by DEA.location Order By DEA.Location, DEA.Date) AS RollingVaccinationTotal,
--(RollingVaccinationTotal/DEA.population)*100
FROM PortfolioProject1..COVIDDeaths$ AS DEA
JOIN PortfolioProject1..COVIDVaccinations$ AS VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
Where DEA.continent is not null
ORDER BY 1,2,3

-- USE CTE

WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationTotal)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(cast(VAC.new_vaccinations AS Int)) OVER (Partition by DEA.location Order By DEA.Location, DEA.Date) AS RollingVaccinationTotal
--(RollingVaccinationTotal/DEA.population)*100
FROM PortfolioProject1..COVIDDeaths$ AS DEA
JOIN PortfolioProject1..COVIDVaccinations$ AS VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
Where DEA.continent is not null
--ORDER BY 1,2,3
)
SELECT *, (RollingVaccinationTotal/Population)*100
FROM PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationTotal numeric
)

Insert into #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(cast(VAC.new_vaccinations AS Int)) OVER (Partition by DEA.location Order By DEA.Location, DEA.Date) AS RollingVaccinationTotal
--(RollingVaccinationTotal/DEA.population)*100
FROM PortfolioProject1..COVIDDeaths$ AS DEA
JOIN PortfolioProject1..COVIDVaccinations$ AS VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
Where DEA.continent is not null
--ORDER BY 1,2,3
SELECT *, (RollingVaccinationTotal/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(cast(VAC.new_vaccinations AS Int)) OVER (Partition by DEA.location Order By DEA.Location, DEA.Date) AS RollingVaccinationTotal
--(RollingVaccinationTotal/DEA.population)*100
FROM PortfolioProject1..COVIDDeaths$ AS DEA
JOIN PortfolioProject1..COVIDVaccinations$ AS VAC
	ON DEA.location = VAC.location
	and DEA.date = VAC.date
Where DEA.continent is not null
--ORDER BY 1,2,3

SELECT *
FROM PercentPopulationVaccinated