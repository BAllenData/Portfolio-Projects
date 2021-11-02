
--Looking at columns in the deaths dataset
Select *
From PortfolioProject..COVIDdeaths$
order by 3,4


--Looking at columns in the vaccinations dataset
select *
from PortfolioProject..COVIDvaccinations$
order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..COVIDdeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths for the United States

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..COVIDdeaths$
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got COVID in the United States
Select Location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
From PortfolioProject..COVIDdeaths$
Where location like '%states%'
order by 1,2 

--Looking at Countries with Highest Infection Rate compared to Population, sorted Desc to see highest infection rate countries first

Select Location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionRate
From PortfolioProject..COVIDdeaths$
--Where location like '%states%'
Group by Location, Population
order by InfectionRate desc


----Show couintries with the highest death count per capita
----added 'where continent is not null' because dataset lists continents in Location column similar to a country, but with a null value for continent.  this filter prevents continents from being included with countries.
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount, MAX((total_cases/population))*100 as InfectionRate
From PortfolioProject..COVIDdeaths$
where continent is not null
--Where location like '%states%'
Group by Location
order by TotalDeathCount desc


----Break it down by continent
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount, MAX((total_cases/population))*100 as InfectionRate
From PortfolioProject..COVIDdeaths$
where continent is null
--Where location like '%states%'
Group by location
order by TotalDeathCount desc

--Second method (just for viz).  This actually does not provide the correct totals because some Location values are not properly associated with a continent value.  When filtered this way, the values for North America include only the United States.
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount, MAX((total_cases/population))*100 as InfectionRate
From PortfolioProject..COVIDdeaths$
where continent is not null
--Where location like '%states%'
Group by continent
order by TotalDeathCount desc



--Showing continents with the highest death count per capita

--New cases, new deaths by day.

Select date, SUM(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..COVIDdeaths$
--Where location like '%states%'
where continent is not null
group by date
order by 1,2


--What is the global case count, global death count, global death rate?
Select SUM(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..COVIDdeaths$
--Where location like '%states%'
where continent is not null
order by 1,2


--Loking at Total Population vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(convert(numeric,new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativePeopleVaccinated
From PortfolioProject..COVIDdeaths$ dea
Join PortfolioProject..COVIDvaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


--Use CTE

;With PopVsVac (Continent, Location, Date, Population, new_vaccinations, CumulativePeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(convert(numeric,new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativePeopleVaccinated
From PortfolioProject..COVIDdeaths$ dea
Join PortfolioProject..COVIDvaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3)
)

Select *, (CumulativePeopleVaccinated/Population)*100 as RollingPctVaccinated
From PopVsVac

-- TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativePeopleVaccinated numeric)

Insert into  #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(convert(numeric,new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativePeopleVaccinated
From PortfolioProject..COVIDdeaths$ dea
Join PortfolioProject..COVIDvaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3)

Select *,(CumulativePeopleVaccinated/Population)*100 as RollingPctVaccinated
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Go
Create View PercentPopulationVaccinated as 

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(convert(numeric,new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativePeopleVaccinated
From PortfolioProject..COVIDdeaths$ dea
Join PortfolioProject..COVIDvaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3)

