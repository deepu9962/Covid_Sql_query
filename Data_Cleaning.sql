--The following queries are just to show how to clean your data
--First we'll take a look at the Housing data that we imported

select * from  project1..NashvilleHousing 

---------------------------------------------------------------------------------------
--Standardize the date format

Alter table project1..NashvilleHousing Add SaleDates Date
Update project1..NashvilleHousing Set SaleDates = CONVERT(Date, SaleDate)
select SaleDates from project1..NashvilleHousing

---------------------------------------------------------------------------------------
--Property Address Data

select PropertyAddress from project1..NashvilleHousing where PropertyAddress is null

select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress
from project1..NashvilleHousing a 
Join project1..NashvilleHousing b 
on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from project1..NashvilleHousing a 
Join project1..NashvilleHousing b 
on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------
--Breaking out the address into different sections

select substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1), 
substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
from  project1..NashvilleHousing 


Alter table project1..NashvilleHousing Add PropertSplitAddress nvarchar(255)
Update project1..NashvilleHousing Set PropertSplitAddress = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)
select PropertSplitAddress from project1..NashvilleHousing

Alter table project1..NashvilleHousing Add city nvarchar(255)
Update project1..NashvilleHousing Set city = substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
select city from project1..NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1) from  project1..NashvilleHousing 

Alter table project1..NashvilleHousing Add OwnerSplitAddress nvarchar(255)
Update project1..NashvilleHousing Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
select OwnerSplitAddress from project1..NashvilleHousing

Alter table project1..NashvilleHousing Add OwnerSplitCity nvarchar(255)
Update project1..NashvilleHousing Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
select OwnerSplitCity from project1..NashvilleHousing

Alter table project1..NashvilleHousing Add OwnerSplitState nvarchar(255)
Update project1..NashvilleHousing Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)
select OwnerSplitState from project1..NashvilleHousing

------------------------------------------------------------------------------------------
--Changing Y and N to 'Yes' and 'No' Respectively

select Distinct(SoldAsVacant), count(SoldAsVacant) from  project1..NashvilleHousing 
Group by SoldAsVacant order by 2

Update project1..NashvilleHousing 
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						ELSE SoldAsVacant
						END

--------------------------------------------------------------------------------------------
--Removing duplicate Rows
WITH RowNumCTE AS(
Select *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From project1.dbo.NashvilleHousing
--order by ParcelID
)
--DELETE Clause was used previously in the next line to delete the duplicate rows and then the select clause is used to check whether duplicates has been deleted
Select *     
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

------------------------------------------------------------------------------------------------
---Delete unwanted  columns
select * from  project1..NashvilleHousing  Order by 2,1

ALTER TABLE project1..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

-------------------------------------------------------------------------------------------------
