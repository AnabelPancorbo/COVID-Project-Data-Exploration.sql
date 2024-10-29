

Select * 
From covid_project..CovidDeaths
Where continent is not null -- Because otherwise the location is a continent
Order by 3,4

--Select * 
--From covid_project..CovidVaccinations

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From covid_project..CovidDeaths
Where continent is not null
Order by 1,2



-- We will review Total Cases vs Total Deaths
--Indicates the probability of mortality if you contract COVID-19 

Select Location, date, total_cases, total_deaths, Round((total_deaths/total_cases)*100,3) as Death_Percentage
From covid_project..CovidDeaths
Where continent is not null
Order by 1,2

--Indicates the probability of mortality if you contract COVID-19 in United States

Select Location, date, total_cases, total_deaths, Round((total_deaths/total_cases)*100,3) as Death_Percentage
From covid_project..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2



-- We will review Total Cases vs Population
--Indicates the proportion of the population that has contracted COVID-19 in United States

Select Location, date, population, total_cases, Round((total_cases/population)*100,3) as Percentage_Population_Infected
From covid_project..CovidDeaths
Where location like '%states%'
Order by 1,2



-- Countries with Highest Infection Rate vs Population

Select Location, population, MAX(total_cases) as Highest_Infection_Count, ROUND(MAX((total_cases/population))*100,3) as Percentage_Population_Infected
From covid_project..CovidDeaths
--Where location like '%states%'
Group by Location, population
Order by Percentage_Population_Infected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as Total_Death_Count 
From covid_project..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
Order by Total_Death_Count  desc



--BREAKING PARAMETERS BY CONTINENT--

-- Continents with Highest Death Count per Population -- creating a graph

Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count  
From covid_project..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by Total_Death_Count  desc



-- WORLDWIDE NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covid_project..CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covid_project..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


Select *
From covid_project..CovidDeaths cd
Join covid_project..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date




-- Total Population vs Vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order By cd.location, cd.date) as Rolling_People_Vaccinated
From covid_project..CovidDeaths cd
Join covid_project..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by 2,3


-- Using CTE conduct calculation on the previous query 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order By cd.location, cd.date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From covid_project..CovidDeaths cd
Join covid_project..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
)
Select *, (Rolling_People_Vaccinated/population)*100
From PopvsVac 


-- TEMP TABLE

--DROP Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #Percent_Population_Vaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order By cd.location, cd.date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From covid_project..CovidDeaths cd
Join covid_project..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 

Select *, (Rolling_People_Vaccinated/population)*100
From #Percent_Population_Vaccinated 




--Creating a View to retain data for future visualizations

Create View Percent_Population_Vaccinated as 
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order By cd.location, cd.date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From covid_project..CovidDeaths cd
Join covid_project..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 