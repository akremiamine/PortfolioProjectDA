Select * 
from PortfolioProject.dbo.CovidDeaths
order by 3,4


--Select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- select data that we are going to be using 

Select location, date , total_cases , new_cases,total_deaths,population
from PortfolioProject.dbo.CovidDeaths
order by 1 , 2

-- looking at total cases vs total deaths  
Select location, date , total_cases ,total_deaths,(total_deaths/total_cases )*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1 , 2

--looking at total cases vs population 
Select location, date , total_cases ,total_deaths ,population , (total_cases /population )*100 as infectionRate
from  PortfolioProject.dbo.CovidDeaths
where location like '%tun%'
order by 1 , 2



--looking at countries with highest infectionRate compared to population
Select location,population , MAX(total_cases)as HighestInfectionRate, MAX(total_cases /population )*100 as infectionRate
from  PortfolioProject.dbo.CovidDeaths
group by population ,location
--order by infectionRate desc (decroissant)
order by infectionRate desc

-- showing Countries with Highest Death Count per Population 
Select location,MAX(cast(Total_deaths as int)) as TotalDeathCount -- cast(Total_deaths as int) car ki n7elou tableau 3ala isar w nemchiw l columns w ki nchofo Total_deaths column na9aoh nvarchar
from  PortfolioProject.dbo.CovidDeaths
where continent is not Null -- 5ater 9a3ed ya3tini fi locaton europe , asia w na7na 7ajetna ken bel bolden ki njiw ncoufo data na9aw eli wa9t continent is Null location tabda esm 9ara    
group by  location 
order by TotalDeathCount desc

-- showing contient with Highest Death Count per Population
Select continent , Max(cast(Total_deaths as int )) as TotalDeathCount
from  PortfolioProject.dbo.CovidDeaths
where continent is  not Null
group by  continent 
order by TotalDeathCount desc

--DeathPercentage par data 
Select  date , SUM(new_cases)as total_cases , SUM(cast(new_deaths as int )) as total_deaths , SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is  not Null
Group by date
order by 1 , 2

--DeathPercentage in total date  
Select  SUM(new_cases)as total_cases , SUM(cast(new_deaths as int )) as total_deaths , SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is  not Null
order by 1 , 2
------------------------------------------
-- looking at Total Population vs Total Vaccination
Select *
From PortfolioProject..CovidVaccinations vacc
join PortfolioProject..CovidDeaths dea
on dea.date = vacc.date
and dea.location = vacc.location
-- looking at Total Population vs Total Vaccination
Select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations -- lezem n7adadou mnin bech njibou donne 7ata ken kif kif fi zouz data
From PortfolioProject..CovidVaccinations vacc
join PortfolioProject..CovidDeaths dea
on dea.date = vacc.date
and dea.location = vacc.location
where dea.continent is not null
order by 1,2,3

-- looking at Total Population vs Total Vaccination
Select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations ,SUM(CONVERT(int,vacc.new_vaccinations))  over (partition by dea.Location Order by dea.location,dea.Date)as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vacc
join PortfolioProject..CovidDeaths dea
on dea.date = vacc.date
and dea.location = vacc.location
where dea.continent is not null
order by 2,3

-- Use temp / CTE tablau 3ala 5ater najmuch nasn3o case w nzido na3mlou 3leha operation jdida (RollingPeopleVaccinated)
Select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations ,SUM(CONVERT(int,vacc.new_vaccinations))  over (partition by dea.Location Order by dea.location,dea.Date)as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidVaccinations vacc
join PortfolioProject..CovidDeaths dea
on dea.date = vacc.date
and dea.location = vacc.location
where dea.continent is not null
order by 2,3
--to solvied CTE
with PopvsVac (continent , location ,Date , Population , New_Caccination ,RollingPeopleVaccinated) -- lezem 9ad colum eli fi with 9ad eli croud
as
(
Select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations ,SUM(CONVERT(int,vacc.new_vaccinations))  over (partition by dea.Location Order by dea.location,dea.Date)as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidVaccinations vacc
join PortfolioProject..CovidDeaths dea
on dea.date = vacc.date
and dea.location = vacc.location
where dea.continent is not null
)
Select * ,(RollingPeopleVaccinated/population)*100 -- lezem traneha m3a CTE !!
from PopvsVac

-- temp table
DROP Table if exists #PercentPopulationVaccinated -- 5ater ki tabdel feha 7aja w t7eb t3awed traneha t9olek table heka mawjoud 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (225),
Location nvarchar (225),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
)
insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations ,SUM(CONVERT(int,vacc.new_vaccinations))  over (partition by dea.Location Order by dea.location,dea.Date)as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidVaccinations vacc
join PortfolioProject..CovidDeaths dea
on dea.date = vacc.date
and dea.location = vacc.location
where dea.continent is not null

Select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-- Creating View to store date for later visualization 
create view PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations ,SUM(CONVERT(int,vacc.new_vaccinations))  over (partition by dea.Location Order by dea.location,dea.Date)as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidVaccinations vacc
join PortfolioProject..CovidDeaths dea
on dea.date = vacc.date
and dea.location = vacc.location
where dea.continent is not null

Select * 
from PercentPopulationVaccinated
