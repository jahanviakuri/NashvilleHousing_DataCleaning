--exploring nashvillehousing data

select * from Protfolioproject..NashvilleHousing

SELECT UniqueID,ParcelID,PropertyAddress,SaleDate,OwnerAddress from Protfolioproject..NashvilleHousing 

--update date format 
-- here if we directly update saledate=covert(date,saledate) its not getting updated 
--so we first alter table by create additional column then update then drop previous column

select SaleDate,CONVERT(Date,SaleDate) as StandardDate from Protfolioproject..NashvilleHousing

ALTER TABLE Protfolioproject..NashvilleHousing
Add SaleDateConverted Date;

update Protfolioproject..NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate) 


select * from Protfolioproject..NashvilleHousing


--replacing NULL based ParcelID in both Popertyaddress and owneraddress
--since we observe that for same parceid both property and owner address are same
--when we replace id shoule be unique otherwise after joining null will be replaced by null

SELECT UniqueID,ParcelID,PropertyAddress,SaleDateConverted,OwnerAddress from Protfolioproject..NashvilleHousing order by ParcelID

SELECT h1.ParcelID,h1.PropertyAddress,h2.ParcelID,h2.PropertyAddress from Protfolioproject..NashvilleHousing h1
join Protfolioproject..NashvilleHousing h2
on h1.ParcelID=h2.ParcelID
and h1.[UniqueID ] <> h2.[UniqueID ]
where h1.PropertyAddress is NULL
order by h1.ParcelID 

update h1
set PropertyAddress = ISNULL(h1.PropertyAddress,h2.PropertyAddress)
from Protfolioproject..NashvilleHousing h1
join Protfolioproject..NashvilleHousing h2
on h1.ParcelID=h2.ParcelID
and h1.[UniqueID ] <> h2.[UniqueID ]
where h1.PropertyAddress is NULL

----breaking address (address,city,state)

SELECT PropertyAddress,OwnerAddress from Protfolioproject..NashvilleHousing 

---property address

select PropertyAddress,
substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as PropAddress,
substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) as PropCity
from Protfolioproject..NashvilleHousing 

Alter table Protfolioproject..NashvilleHousing 
add PropAddress Nvarchar(255),PropCity Nvarchar(255)

update Protfolioproject..NashvilleHousing 
set PropAddress = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1),
PropCity  = substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) 

SELECT PropAddress,PropCity from Protfolioproject..NashvilleHousing 


--owner address

SELECT OwnerAddress from Protfolioproject..NashvilleHousing 
--using CTE
WITH CTE_ADDRESS ( OwnerAddress,OwnAddress,OwnCity)
as
(
select OwnerAddress,
substring(OwnerAddress,1,charindex(',',OwnerAddress)-1) ,
substring(OwnerAddress,charindex(',',OwnerAddress)+1,charindex(',',OwnerAddress)-1) 

from Protfolioproject..NashvilleHousing 
)
select *,
substring(OwnCity,1,charindex(',',OwnCity)) as Ownercity,
substring(OwnCity,charindex(',',OwnCity)+1,LEN(OwnCity)) as pincode
 from CTE_ADDRESS

 --using parsename

 Select OwnerAddress
From Protfolioproject..NashvilleHousing 

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Protfolioproject..NashvilleHousing 



Alter table Protfolioproject..NashvilleHousing 
add OwnAddress Nvarchar(255),OwnCity Nvarchar(255),Pincode Nvarchar(255)
 
update Protfolioproject..NashvilleHousing 
set OwnAddress =PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
OwnCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
Pincode = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT OwnAddress,OwnCity,Pincode from Protfolioproject..NashvilleHousing 

Alter table Protfolioproject..NashvilleHousing 
Drop column OwnerAddress

select * from Protfolioproject..NashvilleHousing 

----chnage y to yes and n to no in soldasvacant column

select SoldAsVacant,count(SoldAsVacant) from Protfolioproject..NashvilleHousing  group by SoldAsVacant

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Protfolioproject..NashvilleHousing 

update Protfolioproject..NashvilleHousing 
set SoldAsVacant=CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

---remove duplicates here unique id is differenet but we ignor that column
--get duplicate rows
--row_num() gives row numbers we use partition instead group by since
--group by groups all rows ,
--partition by groups based on given critirea 
--using rownum we give ranking 1 if it once 2 if row is repeated twice...
WITH ROWNUMCTE AS
(
select *,
row_number() over(partition by ParcelID,PropAddress,SalePrice,SaleDateConverted,legalReference order by UniqueID) as rownum
From Protfolioproject..NashvilleHousing
)select * from ROWNUMCTE where rownum>1

--deleted duplicate

WITH ROWNUMCTE AS
(
select *,
row_number() over(partition by ParcelID,PropAddress,SalePrice,SaleDateConverted,legalReference order by UniqueID) as rownum
From Protfolioproject..NashvilleHousing
)delete from ROWNUMCTE where rownum>1

---delete unused columns

Alter table Protfolioproject..NashvilleHousing 
Drop column PropertyAddress

Alter table Protfolioproject..NashvilleHousing 
Drop column SalesDate

Alter table Protfolioproject..NashvilleHousing 
Drop column OwnerAddress

