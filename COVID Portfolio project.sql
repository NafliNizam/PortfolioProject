select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4
--Select Data that we are going to be using

select  location,date, total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at Total cases vs Total Deaths
--Shows lkelihood of dying if you cntract covid in your country

select  location,date, total_cases, total_deaths, cast(total_deaths as float)/(total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%lanka%'
order by 1,2

--Looking at Total cases vs Population
--shows what percentage of population got Covid

select  location,date, population, total_cases,  (total_cases)/(Population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%lanka%'
order by 1,2


--Looking at countries with highest infection rate compared to Population

/*select  location, population, Max(total_cases) as HighestInfectionCount,  Max(total_cases)/Population*100 
	as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%lanka%'
group by location, population
order by PercentPopulationInfected desc*/

/*select location,max(cast(total_cases as int)) as Maxi, population
from PortfolioProject..CovidDeaths
where location like '%lanka%'
group by location, population
*/

select location, population, max(cast(total_cases as int)) as HighestInfectionCount , 
 max(cast(total_cases as int))/population *100 as PercentPopulationInfect
from portfolioProject..covidDeaths
where location like '%lanka%'
group by location, population
order by PercentPopulationInfect desc


--Showing the countries with highest Death count per population

select location, population, max(cast(total_deaths as int)) as TotalDeathCount  
 --max(cast(total_cases as int))/population *100 as PercentPopulationInfect
from portfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by TotalDeathCount desc


--Let's break things down by continent
--showing continent with the highest death count

select continent, max(cast(total_deaths as int)) as TotalDeathCount  
from portfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--global  numbers

select date, sum(new_cases) as total_Cases, sum(cast(new_deaths as int)) total_Deaths,
sum(cast(new_deaths as int))/nullif(IsNull(sum(new_cases),0),0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2



--overall cases
select  sum(new_cases) as total_Cases, sum(cast(new_deaths as int)) total_Deaths,
sum(cast(new_deaths as int))/nullif(IsNull(sum(new_cases),0),0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.New_Vaccinations,
Sum(Convert(bigint,Vac.new_Vaccinations)) over (Partition by Dea.location order by Dea.location,Dea.date ) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
	on  Dea.location = Vac.Location
	and Dea.Date = Vac.Date
where Dea.continent is not null
order by 2,3

--USE CTE

with PopVsVac (Continent,location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.New_Vaccinations,
Sum(Convert(bigint,Vac.new_Vaccinations)) over (Partition by Dea.location order by Dea.location,Dea.date ) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
	on  Dea.location = Vac.Location
	and Dea.Date = Vac.Date
where Dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac


--Temp Table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.New_Vaccinations,
Sum(Convert(bigint,Vac.new_Vaccinations)) over (Partition by Dea.location order by Dea.location,Dea.date ) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
	on  Dea.location = Vac.Location
	and Dea.Date = Vac.Date
--where Dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualization

create view PercentPopulationVaccinated as
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.New_Vaccinations,
Sum(Convert(bigint,Vac.new_Vaccinations)) over (Partition by Dea.location order by Dea.location,Dea.date ) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
	on  Dea.location = Vac.Location
	and Dea.Date = Vac.Date
where Dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated

