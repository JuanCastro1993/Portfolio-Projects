select * 
from PortafolioProject.dbo.CovidVacinations
order by 3,4



select Location, date, total_cases, new_cases, total_deaths, population
from PortafolioProject.dbo.CovidDeaths
order by 3,4


--Selecting total cases and total deaths by country, in this case Dominican Republic.

select Location, date,total_cases, total_deaths
From PortafolioProject.dbo.CovidDeaths
where Location like '%Dominican Republic%'
order by 1,2


---Loking at the total cases vs Population

select Location, date,total_cases,Population,  (total_cases/population)*100 as DeathPorcentage
From PortafolioProject.dbo.CovidDeaths
where Location like '%Dominican Republic%'
order by 1,2

--Loking at Country whith Highest Infection rate compared to population

select Location,Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as DeathPorcentage
From PortafolioProject.dbo.CovidDeaths
--where Location like '%Dominican Republic%'
group by Location, Population
order by DeathPorcentage desc


---Showing countries with the highest Death Count Per Population 

select Location, Max(cast(total_deaths as Int)) as TotalDeathsCount
From PortafolioProject.dbo.CovidDeaths
--where Location like '%Dominican Republic%'
group by Location
order by TotalDeathsCount desc

---Showing all the Information by Continent

select continent, Max(cast(total_deaths as Int)) as TotalDeathsCount
From PortafolioProject.dbo.CovidDeaths
--where Location like '%Dominican Republic%'
where continent is not null
group by continent
order by TotalDeathsCount desc

---Looking at Total population vs Vaccination

Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
from PortafolioProject.dbo.CovidDeaths as Dea
Join PortafolioProject.dbo.CovidVacinations as Vac
	on Dea.Location = Vac.Location
	and Dea.date = Vac.date
where Dea.continent is not null
Order by 2,3

---USE CTE
--with PopVsVac (Continent,Location, Date, Population, new_Vaccinations,RollingPeopleVaccinated)
--as
--(
--select Dea.continent, dea.location, dea.date, Dea.population, Vac.new_vaccinations
--, SUM (CONVERT (int, Vac.new_vaccinations)) OVER (Partition by dea.Location Order by Dea.location, dea.date) 
--as  RollingPeopleVaccinated
--from PortafolioProject..CovidDeaths Dea
--Join PortafolioProject..CovidVaccinations Vac
--	on Dea.Location = Vac.location
--	and Dea.Date = Vac.Date
--Where Dea.continent is Not Null

--Select * , (RollingPeopleVaccinated/population )*100
--from PopVsVac


---TEMP TABLE

--CREATE TABLE #PercentPopulationVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar (255),
--Date  datetime,
--Population Numeric,
--New_Vaccinations Numeric,
--RollingPeopleVaccinated Numeric
--)

--insert into #PercentPopulationVaccinated
--select Dea.continent, dea.location, dea.date, Dea.population, Vac.new_vaccinations,
--SUM(CONVERT (int,Vac.new_vaccinations)) Over (Partition by dea.location Order by Dea.location, dea.date)
--as  RollingPeopleVaccinated
--from PortafolioProject..CovidDeaths Dea
--	Join PortafolioProject..CovidVaccinations Vac
--	on Dea.Location = Vac.location
--	and Dea.Date = Vac.Date
--Where Dea.continent is not null

--Select * , (RollingPeopleVaccinated/population )*100
--from #PercentPopulationVaccinated


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortafolioProject..CovidDeaths dea
Join PortafolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
-------

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
