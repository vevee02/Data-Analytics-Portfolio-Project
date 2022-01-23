-- Cleaning Data in SQL Queries using Nashville Housing Data

Select *
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--STANDARDIZE DATE FORMAT
--This will format the date column to its proper date format, without the time included.

USE PortfolioProject
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA
--There are some rows with the property address being null, however those rows share the same parcel ID with the rows that do not have property address being null. This query will join the two and populate property address in the row where its property address is null.

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--SEPARATING THE ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

-- delimiter will be used, substring, and character index

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

--after separating the values we now have to create two new columns

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 

Select *
From PortfolioProject.dbo.NashvilleHousing

-- here is another way to split an address. instead of using string, I will use parse name. I will try this on OwnerAddress.

Select
PARSENAME(REPLACE(OwnerAddress, ',' , '.' ) , 3) 
,PARSENAME(REPLACE(OwnerAddress, ',' , '.' ) , 2) 
,PARSENAME(REPLACE(OwnerAddress, ',' , '.' ) , 1) 
From PortfolioProject.dbo.NashvilleHousing

USE PortfolioProject
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.' ) , 3)  

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.' ) , 2)  

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.' ) , 1) 

Select *
From NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

--there are some values that should be written out completely as yes or no, but is written as y and n in the field.

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--REMOVE DUPLICATES

--cte, then windows function to find duplicate values and delete them

WITH RowNumCTE As(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num

From PortfolioProject.dbo.NashvilleHousing

)
DELETE
From RowNumCTE
Where row_num > 1

--now to check if there are duplicate values to make sure

WITH RowNumCTE As(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num

From PortfolioProject.dbo.NashvilleHousing

)
Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

Select *
From PortfolioProject.dbo.NashvilleHousing

