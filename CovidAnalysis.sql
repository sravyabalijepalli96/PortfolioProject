select * from PortfolioProject..CovidVaccinations where continent is not null order by 3,4

 select * from PortfolioProject..CovidDeaths order by 3,4

 -- Select the data that we are going to be using

 Select location,date,total_cases,new_cases, total_deaths,population
 from PortfolioProject..CovidDeaths order by 1,2

 -- Looking at Total Cases vs Total Deaths
 --Shows chances of dying if you contract covid in India

 select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 where location like '%India%'
 order by 1,2

 -- Looking at Total cases vs Population 
 -- Shows what percentage of population got Covid
  
  select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 where location like '%India%'
 order by 1,2

 --Looking at the countries with highest infection rate compared to population

 select location, population, max(total_cases) as HighestInfectionCountry, max(total_cases/population)*100 as PopulationInfected
 from PortfolioProject..CovidDeaths
 --where location like '%India%'
 group by location, population
 order by PopulationInfected desc

 --Showing countries with highest death count per population

  select location, population, max(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths
 --where location like '%India%'
 where continent is not null
 group by location, population
 order by TotalDeathCount desc


-- Grouping/ displaying the results by continent

  select location, max(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths
 --where location like '%India%'
 where continent is null
 group by location
 order by TotalDeathCount desc

 --Breaking things down by continent
 -- Showing results with highest death count by continent

 select continent, max(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths
 --where location like '%India%'
 where continent is not null
 group by continent
 order by TotalDeathCount desc

 --Displaying global numbers (Death percentage over all the globe) - Displays total cases,total deaths and death percentage

   select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 --where location like '%India%'
 where continent is not null
 --group by date
 order by DeathPercentage desc

 --Displaying total cases and deaths grouping by date

  select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 --where location like '%India%'
 where continent is not null
 group by date
 order by DeathPercentage desc

 --Joining both covid deaths and covid vaccinations table
 
 select * from PortfolioProject..CovidDeaths dea
 join
 PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location and dea.date = vac.date

  -- Looking at Total population Vs Vaccinations

 select dea.continent, dea.location, dea.date, dea.population 
 from PortfolioProject..CovidDeaths dea 
 join
 PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location and 
  dea.date = vac.date
 where dea.continent is not null 
  order by 1,2,3
  
  --Location wise vaccinations (Using partition By)

   select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   sum(convert(int,vac.new_vaccinations)) 
   over (partition by dea.location order by dea.location, dea.date) as people_vaccinated
 from PortfolioProject..CovidDeaths dea 
 join
 PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location and 
  dea.date = vac.date
 where dea.continent is not null 
  order by 2,3


  --Using CTE (Common Table Expression)

  With PopvsVac ( Continent, Location, date, population, new_vaccinations, people_vaccinated)
  as
  (
   select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   sum(convert(int,vac.new_vaccinations)) 
   over (partition by dea.location order by dea.location, dea.date) as people_vaccinated
 from PortfolioProject..CovidDeaths dea 
 join
 PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location and 
  dea.date = vac.date
 where dea.continent is not null 
 -- order by 2,3
)
Select *, (people_vaccinated/population)*100 from PopvsVac

--Using temp table


drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
 new_vaccinations numeric,
 people_vaccinated numeric)

 insert into #PercentPopulationVaccinated
 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   sum(convert(int,vac.new_vaccinations)) 
   over (partition by dea.location order by dea.location, dea.date) as people_vaccinated
 from PortfolioProject..CovidDeaths dea 
 join
 PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location and 
  dea.date = vac.date
 where dea.continent is not null 
 -- order by 2,3
 
 Select *, (people_vaccinated/population)*100 from #PercentPopulationVaccinated

 --creating view to store data for later visualizations

 create view PercentPopulationvaccinated as 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   sum(convert(int,vac.new_vaccinations)) 
   over (partition by dea.location order by dea.location, dea.date) as people_vaccinated
 from PortfolioProject..CovidDeaths dea 
 join
 PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location and 
  dea.date = vac.date
 where dea.continent is not null 
 --order by 2,3

 select * from PercentPopulationvaccinated