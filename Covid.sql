SELECT * FROM PortfolioProject.coviddeaths
where continent <> '0';

-- SELECT * FROM PortfolioProject.covidvaccinations;


-- Select the data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.coviddeaths;

-- Looking at total cases vs. total deaths
-- Shows the likelihood of dying if you contract covid in your country (USA)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject.coviddeaths
Where location like '%states%';

-- Looking at Total Cases vs Population (USA)
-- Shows what percentage of the population has gotten covid as of 4/30/2021 - about 10% of the population
SELECT location, date, total_cases, population, (total_cases/population)*100 as population_percentage
FROM PortfolioProject.coviddeaths
Where location like '%states%';

-- What countries have the highest infection rates? Top 3: Andorra, Montenegro, Czechia
-- Looking at countries with highest infection rate compared to population
SELECT location, population, max(total_cases) as highest_infection_ct, max((total_cases/population))*100 as population_pct_infected
FROM PortfolioProject.coviddeaths
GROUP BY location, population
ORDER BY population_pct_infected desc;

-- What countries have the highest death COUNT?
-- Looking at countries with highest death COUNT
-- Total deaths in the original dataset was a string but I converted it to int when importing the data, otherwise it is possible to use 'cast(total_deaths as int) for the time being
SELECT location, max(total_deaths) as highest_death_ct 
FROM PortfolioProject.coviddeaths
where continent <> '0'
GROUP BY location
ORDER BY highest_death_ct desc;

-- What countries have the highest death rate?
-- Looking at countries with highest death rate compared to population
SELECT location, population, max(total_deaths) as highest_death_ct, max((total_deaths/population))*100 as population_pct_death
FROM PortfolioProject.coviddeaths
where continent <> '0'
GROUP BY location, population
ORDER BY population_pct_death desc;


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count

SELECT continent, max(total_deaths) as highest_death_ct 
FROM PortfolioProject.coviddeaths
where continent <> '0'
GROUP BY continent
ORDER BY highest_death_ct desc;


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_pct -- total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject.coviddeaths
WHERE continent <> '0';
-- Group by date;

-- Looking at Total Population vs Vaccinations
-- Partition by location makes it only find new vax numbers for each location

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (PARTITION BY dea.location ORDER BY dea.location, CAST(dea.date AS datetime)) as RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent <> '0';

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (PARTITION BY dea.location ORDER BY dea.location, CAST(dea.date AS datetime)) as RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent <> '0'
)

SELECT *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- TEMP TABLE

SHOW COLUMNS FROM PortfolioProject.coviddeaths;

DROP Table if exists PeopleVaccinated;
CREATE TABLE PeopleVaccinated (
continent varchar(45),
location varchar(45),
date varchar(45),
new_vaccinations numeric,
population numeric,
RollingPeopleVaccinated numeric
);

Insert into PeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent <> '0';

-- Creating View to store data for later visualizations

CREATE VIEW PctPeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent <> '0'
