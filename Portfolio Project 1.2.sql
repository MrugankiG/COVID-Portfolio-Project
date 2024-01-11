/*
Cleaning Data in SQL Queries
*/

--SELECT *
--FROM PortfolioProject.dbo.NashvilleHousing$

---------------------------------------------------------------------------

--Standardize Date Format

SELECT SaleDateUpdated, CONVERT(Date, SaleDAte)
FROM PortfolioProject.dbo.NashvilleHousing$

UPDATE NashvilleHousing$
SET SaleDate = CONVERT(Date, SaleDAte)

ALTER TABLE NashvilleHousing$
ADD SaleDateUpdated Date;

UPDATE NashvilleHousing$
SET SaleDateUpdated = CONVERT(Date, SaleDate)



---------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM PortfolioProject..NashvilleHousing$
--WHERE PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$ b
	on   a.ParcelId = b.ParcelId
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$ b
	on   a.ParcelId = b.ParcelId
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


----------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing$


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address 
FROM PortfolioProject.dbo.NashvilleHousing$

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.NashvilleHousing$

ALTER TABLE NashvilleHousing$
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing$
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing$




SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing$

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing$

ALTER TABLE NashvilleHousing$
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing$
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing$
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-----------------------------------------------------------------------------

--Change Y and N to Yes adn No in 'Sold as vacant' field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing$
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing$


UPDATE NashvilleHousing$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
						When SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

----------------------------------------------------------------------------

--Remove Duplicates

--CTE + Window Functions

WITH RowNumCTE as (
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
				     PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID
					 ) row_num
FROM PortfolioProject.dbo.NashvilleHousing$
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
Where row_num > 1
--Order by PropertyAddress



---------------------------------------------------------------------------

-- Deleting Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing$

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
DROP COLUMN SaleDate

