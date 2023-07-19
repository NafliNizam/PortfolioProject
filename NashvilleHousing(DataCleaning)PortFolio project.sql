select SaleDateConvedrted
from PortfolioProject.dbo.NashvilleHousing

--Standadize Date Format

select SaleDateConverted, CONVERT(Date, SaleDate) 
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

--Creating a column name saleDateConverted to convert the Date format

ALTER Table NashvilleHousing
ADD SaleDateConverted Date;
--Update the date
update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--Populate Property Data

select *
from PortfolioProject.dbo.NashvilleHousing
--where propertyAddress is null
order by ParcelId

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.propertyAddress is null


update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.propertyAddress is null

--Breaking out address into individual Column(Address, City, State)

select propertyAddress
from PortfolioProject.dbo.NashvilleHousing

select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',propertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',',propertyAddress) +1,LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

-- Adding two new column to add addresa by address and city
ALTER Table NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',propertyAddress)-1)

ALTER Table NashvilleHousing
ADD PropertySplitCity nvarchar(255);

update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',propertyAddress) +1,LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing

--Same thin we need to do to the owners address
select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

--different mathod 
select
PARSENAME (REPLACE (OwnerAddress,',','.') ,3),
PARSENAME (REPLACE (OwnerAddress,',','.') ,2),
PARSENAME (REPLACE (OwnerAddress,',','.') ,1)
from PortfolioProject.dbo.NashvilleHousing



ALTER Table NashvilleHousing
ADD OwnersSplitAddress Nvarchar(255);

update NashvilleHousing
SET OwnersSplitAddress = PARSENAME (REPLACE (OwnerAddress,',','.') ,3)

ALTER Table NashvilleHousing
ADD OwnersSplitCity nvarchar(255);

update NashvilleHousing
SET OwnersSplitCity = PARSENAME (REPLACE (OwnerAddress,',','.') ,2)

ALTER Table NashvilleHousing
ADD OwnersSplitState nvarchar(255);

update NashvilleHousing
SET OwnersSplitState = PARSENAME (REPLACE (OwnerAddress,',','.') ,1)

select *
from PortfolioProject.dbo.NashvilleHousing

--change y and N into yes and No

select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant, 
case  when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	end
from PortfolioProject.dbo.NashvilleHousing


update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = case  when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	end



--Remove Duplicate

WITH RowNumCTE As(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					)row_num
from PortfolioProject.dbo.NashvilleHousing
)
--order by ParcelID
DELETE
from RowNumCTE
where row_num > 1



--Delete Unused Column

select * from
PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate
