-- data cleaning

select * 
from ProtofolioProject.dbo.NashvilleHousing

--------------------------------------------------------

-- standardise data format

select SaleDate, CONVERT(Date,SaleDate)
from ProtofolioProject.dbo.NashvilleHousing

update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

-- it shows an error that the table name isnt unique and i dont know
--how to fix this. In the table, it shows as one.

--------------------------------------------------------------------

--populate property address data

select * 
from ProtofolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
from ProtofolioProject.dbo.NashvilleHousing a
join ProtofolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
from ProtofolioProject.dbo.NashvilleHousing a
join ProtofolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]

-----------------------------------------------------------------------
--Breaking out Address into individual columns (Address, City, State)

select PropertyAddress
from ProtofolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as address

from ProtofolioProject.dbo.NashvilleHousing

-- the -1 gets rid of the comma that comes at the end of the result page.
--remove it to see the difference.


Select OwnerAddress
From ProtofolioProject.dbo.NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From ProtofolioProject.dbo.NashvilleHousing

-- this helps to separate multiple variables which are all 
-- in the same row of a table.

Alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
Set OwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

Alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

Select *
From ProtofolioProject.dbo.NashvilleHousing

----------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select *
From RowNumCTE
where row_num > 1
Order by PropertyAddress



select *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



select *
from PortfolioProject.dbo.NashvilleHousing


alter table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


