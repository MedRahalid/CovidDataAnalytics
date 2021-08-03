select * 
from CovidAnalysis.dbo.CovidDeaths
order by 1,2
select*
from CovidAnalysis..CovidVaccinations
order by 1,2

select location,date,population,total_cases,new_cases, total_deaths , ((cast(total_deaths as decimal))/(cast(total_cases as decimal)))*100 as DeathPercentage
from CovidAnalysis..CovidDeaths


select location,date,total_cases,new_cases,total_deaths,population, ((cast(total_deaths as decimal))/(cast(total_cases as decimal)))*100 as DeathPercentage
from CovidAnalysis..CovidDeaths
order by 1,2


select location,date,population,total_cases, ((cast(total_cases as decimal))/(cast(population as decimal)))*100 as InfectionPercentage
from CovidAnalysis..CovidDeaths
where location like '%africa%'
order by 1,2

---countries with highest infection

select location,date,population,max(total_cases) as MaxCases, max(((cast(total_cases as decimal))/(cast(population as decimal)))*100) as MaxInfectionPercentage
from CovidAnalysis..CovidDeaths
group by location,population,date
order by MaxInfectionPercentage desc

---countries with highest death rate

select location,date,max(total_deaths)  as MaxDeathCount
from CovidAnalysis..CovidDeaths
where continent is not null
group by location,date
order by MaxDeathCount desc

----highest death rate by continent

select continent,MAX(cast(total_deaths as float))  as MaxDeathCount
from CovidAnalysis..CovidDeaths
where continent is not null
group by continent
order by MaxDeathCount desc 

---Global statistics

SELECT SUM(cast(new_cases as float)) as total_new_cases, sum(cast(new_deaths as float)) as total_deaths, (sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as GlobalDeathPercentage
from CovidAnalysis..CovidDeaths
--where continent is not null
order by 1,2

---total population vs vaccination rate 
select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations
from CovidAnalysis..CovidDeaths dea 
join CovidAnalysis..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date 
where dea.continent is not null and vac.new_vaccinations is not null
order by 5

---total vaccinations
select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from CovidAnalysis..CovidDeaths dea 
join CovidAnalysis..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date 
where dea.continent is not null
order by 2,3

---total vaccinations for morocco

select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from CovidAnalysis..CovidDeaths dea 
join CovidAnalysis..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date 
where dea.location like '%morocco%'
order by 2,3

---total population vs vaccinations percentage

with PopvsVac ( PeopleVaccinated,location,date,population,continent,new_vaccinations)
as 
(
select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from CovidAnalysis..CovidDeaths dea 
join CovidAnalysis..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date 

)
select * , cast(PeopleVaccinated as int) /cast(population as int)*100
from PopvsVac

----vaccinations table

create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)
insert into #PercentagePopulationVaccinated
select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from CovidAnalysis..CovidDeaths dea 
join CovidAnalysis..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date 
where dea.continent is not null
select* , (PeopleVaccinated/population)*100
from #PercentagePopulationVaccinated