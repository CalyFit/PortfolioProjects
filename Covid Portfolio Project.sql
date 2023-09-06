Select *
From [PortfolioProject ].dbo.CovidDeaths
Where Continent is not null
order by 3,4

Select *
From [PortfolioProject ].dbo.CovidVaccinations
Order by 3,4

/*Select Data That we are going to be using*/

Select location, date , total_cases, new_cases,total_deaths,population
from [PortfolioProject ]..CovidDeaths
Order by 1,2

/* Looking at Total cases vs Total Deaths*/

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
order by 1,2

Select total_cases
From [PortfolioProject ].dbo.CovidDeaths

/* Looking at Total cases vs Total Deaths*/
/* Shows the likelihood of dying if you contract covid in your country*/
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
Where location like '%states%'
order by 1,2

--Looking at the Total cases vs Population
--shows what percentage of population got covid
Select location, date,  Population, total_cases,
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, Population), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
Where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population 

Select location, Population, Max(total_cases) as HighestInfectionCount, Max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, Population), 0))) * 100 AS PercentagePopulationInfected
from PortfolioProject..covidDeaths
--Where location like '%states%'
Group by Location,Population 
order by PercentagePopulationInfected DESC

--Showing Countries with the highest death count per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--Where location like '%states%'
Where Continent is not null
Group by Location 
order by TotalDeathCount Desc



--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--Where location like '%states%'
Where Continent is not null
Group by continent 
order by TotalDeathCount Desc

--Showing the continent with highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--Where location like '%states%'
Where Continent is not null
Group by continent 
order by TotalDeathCount Desc

--Global Numbers 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2


--Joining the two tables and then Looking at Total Polpulation VS Vaccination 

Select*
From [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


--Looking at Total Polpulation VS Vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
From [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/Population)*100
From [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as

(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/Population)*100
From [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Then creating a Temp Table below
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/Population)*100
From [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



Creating Views to store Data for visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/Population)*100
From [PortfolioProject ]..CovidDeaths dea
Join [PortfolioProject ]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated