USE portfolio;

SELECT * FROM Covid_deaths
ORDER BY 3,4;

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM Covid_deaths
ORDER BY 1,2; 

---Looking at Total cases vs Total  deaths
---Shows likelihood of dieing if contacted covid in Nigeria
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_Percentage
FROM Covid_deaths 
WHERE location = 'Nigeria' and total_cases IS NOT NULL AND new_cases IS NOT NULL AND total_deaths IS NOT NULL
ORDER BY 1,2;

---Shows likelihood of dieing if contacted covid in UK
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_Percentage
FROM Covid_deaths 
WHERE location = 'United Kingdom' and total_cases IS NOT NULL AND new_cases IS NOT NULL AND total_deaths IS NOT NULL
ORDER BY 1,2;

---Looking at Total cases vs Population
---Shows the percentage of people that got covid
SELECT Location, date, population, total_cases, (total_cases/population) * 100 as Covid_Percentage
FROM Covid_deaths 
WHERE total_cases IS NOT NULL 
ORDER BY 1,2;

---Countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS Highest_infestious_country, MAX((total_cases/population)) * 100 as Highest_Covid_Percentage
FROM Covid_deaths
WHERE total_cases IS NOT NULL 
GROUP  BY Location, population
ORDER BY Highest_Covid_Percentage DESC;


---Showing countries with highest death rate
SELECT Location, MAX(total_deaths) AS Highest_Death_country
FROM Covid_deaths
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP  BY Location
ORDER BY Highest_Death_country DESC;

---Showing continent with highest death rate
SELECT Continent, MAX(total_deaths) AS Highest_Death_continent
FROM Covid_deaths
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP  BY  Continent
ORDER BY Highest_Death_continent DESC;

---SHOWING ACROSS THE WORLD NUMBERS WITH DATE
SELECT date, SUM(new_cases) AS TOTAL_CASES, SUM(new_deaths) AS TOTAL_DEATHS, SUM(new_deaths)/SUM(new_cases) * 100  AS DEATHS_PERCENTAGE
FROM Covid_deaths
WHERE continent IS NOT NULL AND new_cases IS NOT NULL
GROUP BY date
ORDER BY 1,2;

---SHOWING ACROSS THE WORLD NUMBERS WITHOUT DATE
SELECT  SUM(new_cases) AS TOTAL_CASES, SUM(new_deaths) AS TOTAL_DEATHS, SUM(new_deaths)/SUM(new_cases) * 100  AS DEATHS_PERCENTAGE
FROM Covid_deaths
WHERE continent IS NOT NULL AND new_cases IS NOT NULL
ORDER BY 1,2;

--- JOIN THE TABLES TOGETHER
SELECT * 
FROM Covid_deaths AS death
JOIN covid_vaccinations AS vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date;

--- LOOKING AT TOTAL POPULATION VS VACCINATION
SELECT SUM(population) AS TOTAL_POPULATION, SUM(total_vaccinations) AS TOTAL_VACCINATION
FROM Covid_deaths AS death
JOIN covid_vaccinations AS vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date;

----HJJKJNBG
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
FROM Covid_deaths AS death
JOIN covid_vaccinations AS vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE new_vaccinations IS NOT NULL AND death.continent IS NOT NULL
ORDER BY 3,2;

---VBNMBNVB
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CAST(vaccine.new_vaccinations AS FLOAT)) OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS PARTITION
FROM Covid_deaths AS death
JOIN covid_vaccinations AS vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE new_vaccinations IS NOT NULL AND death.continent IS NOT NULL
ORDER BY 3,2;

---LOOKING AT TOTAL PEOPLE VS VACCINATION
---- USE CTE
WITH PopvsVaci(continent, location, Date, Population,new_vaccination, ROLLIIN_PEOPLE_VACCINATED)
AS
(
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CAST(vaccine.new_vaccinations AS FLOAT)) OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS ROLLIIN_PEOPLE_VACCINATED
FROM Covid_deaths AS death
JOIN covid_vaccinations AS vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE new_vaccinations IS NOT NULL AND death.continent IS NOT NULL
)

SELECT *, (ROLLIIN_PEOPLE_VACCINATED/population) * 100 AS ROLLIIN_PEOPLE_VACCINATED_PERCEN
FROM PopvsVaci;


---TEMP TABLE
DROP TABLE IF EXISTS #PercentPeopleVaccinated ---THIS LINE OF CODE IS USEFUL IF YOU WANT TO CHANGE SOMETHING IN THE TEMP TABLE
CREATE TABLE #PercentPeopleVaccinated
(continent NVARCHAR(255), location NVARCHAR(255), date DATETIME, population NUMERIC, new_vaccinations NUMERIC, ROLLIIN_PEOPLE_VACCINATED NUMERIC)

INSERT INTO #PercentPeopleVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CAST(vaccine.new_vaccinations AS FLOAT)) OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS ROLLIIN_PEOPLE_VACCINATED
FROM Covid_deaths AS death
JOIN covid_vaccinations AS vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE new_vaccinations IS NOT NULL AND death.continent IS NOT NULL


SELECT *, (ROLLIIN_PEOPLE_VACCINATED/population) * 100 AS ROLLIIN_PEOPLE_VACCINATED_PERCEN
FROM #PercentPeopleVaccinated;


---- CREATING VIEWS TO STORE DATA FOR VISUALIZION LATER
CREATE VIEW PercentPeopleVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CAST(vaccine.new_vaccinations AS FLOAT)) OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS ROLLIIN_PEOPLE_VACCINATED
FROM Covid_deaths AS death
JOIN covid_vaccinations AS vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE new_vaccinations IS NOT NULL AND death.continent IS NOT NULL

---VIEW EVERYTHING
SELECT * FROM PercentPeopleVaccinated; --- ASSIGNMENT CREATE VIEWS FOR OTHER QUERIES



