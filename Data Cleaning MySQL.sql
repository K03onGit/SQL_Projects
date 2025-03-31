/* creating a copy of the raw table*/

create table layoffscopy
like layoffs;

insert into layoffscopy
select * from layoffs;

select * from layoffscopy;

-- 1. Remove Duplicates

select *, row_number() over(
partition by Company, Location_HQ, Industry, Laid_Off_Count, 'Date', Funds_Raised, Stage, Date_Added, Country, Percentage)
as row_num
from layoffscopy;

with duplicate_cte as (
select *, row_number() over(
partition by Company, Location_HQ, Industry, Laid_Off_Count, 'Date', Funds_Raised, Stage, Date_Added, Country, Percentage)
as row_num
from layoffscopy)
select * from duplicate_cte
where row_num > 1;

-- select any company from the table to confirm there are duplicates

select * from layoffscopy
where Company = 'Silo';

-- create a new table and add those row numbers in. Then delete where row numbers are over 1, then delete that column

CREATE TABLE `layoffscopy1` (
  `Company` text,
  `Location_HQ` text,
  `Industry` text,
  `Laid_Off_Count` text,
  `Date` text,
  `Funds_Raised` double DEFAULT NULL,
  `Stage` text,
  `Date_Added` text,
  `Country` text,
  `Percentage` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffscopy1;

insert into layoffscopy1
select *, row_number() over(
partition by Company, Location_HQ, Industry, Laid_Off_Count, 'Date', Funds_Raised, Stage, Date_Added, Country, Percentage)
as row_num
from layoffscopy;

-- these are the ones we want to delete where the row number is > 1

select * from layoffscopy1
where row_num > 1;

delete from layoffscopy1
where row_num > 1;

-- select the same company as example to check if the duplicates are deleted.

select * from layoffscopy1
where Company = 'Silo';

-- 2. Standardize Data

select Company, trim(Company) from layoffscopy1;

update layoffscopy1
set Company = trim(Company);

-- 3. Setting up the correct data type

alter table layoffscopy1
modify column `Date` date;

alter table layoffscopy1
modify column Date_Added date;

update layoffscopy1
set Laid_Off_Count = null
where Laid_Off_Count = '';
alter table layoffscopy1
modify column Laid_Off_Count integer;

update layoffscopy1
set Percentage = null
where Percentage = '';
alter table layoffscopy1
modify column Percentage decimal(10,1);	

-- 4. Handling Nulls

select * from layoffscopy1
where Laid_Off_Count is null
and Percentage is null;

delete 
from layoffscopy1
where Laid_Off_Count is null
and Percentage is null;

-- Deleting unwanted columns

alter table layoffscopy1
drop column row_num;

select * from layoffscopy1;

	







