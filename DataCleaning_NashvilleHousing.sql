/*
Data Cleaning in SQL Queries
*/

----------------------------------------------------------------------------------------------------------------------------


--Standardize SaleDate


SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM portfolioProject..NashvilleHousing;

UPDATE portfolioProject..NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate);

ALTER TABLE portfolioProject..NashvilleHousing
Add SaleDateConverted date;

UPDATE portfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);


----------------------------------------------------------------------------------------------------------------------------


--Populate Property Address Data


SELECT *
FROM portfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID;

/*
In the join below, I've joined the table to itself only on the ParcelID that does not have the same UniqueID.
*/

SELECT a.UniqueID, a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolioProject..NashvilleHousing a
JOIN portfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolioProject..NashvilleHousing a
JOIN portfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null;


----------------------------------------------------------------------------------------------------------------------------


---Breaking address into individual columns


SELECT PropertyAddress
FROM portfolioProject..NashvilleHousing
--WHERE PropertyAddress is null

--for this we will use a substring and a character index

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM portfolioProject..NashvilleHousing;

ALTER TABLE portfolioProject..NashvilleHousing
Add PropertyAddressSplit Nvarchar(255);

UPDATE portfolioProject..NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE portfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE portfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));


--Splitting the OwnerName into individual columns using PARSENAME()


Select OwnerAddress
FROM portfolioProject..NashvilleHousing;

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM portfolioProject..NashvilleHousing;


ALTER TABLE portfolioProject..NashvilleHousing
Add OwnerAddressSplit Nvarchar(255);

UPDATE portfolioProject..NashvilleHousing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE portfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE portfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE portfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE portfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


----------------------------------------------------------------------------------------------------------------------------


--Change Y and N to 'Yes' and 'No' in SoldAsVacant


SELECT distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM portfolioProject..NashvilleHousing;

UPDATE portfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END;


----------------------------------------------------------------------------------------------------------------------------


--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY UniqueID) row_num
FROM portfolioProject..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress;


----------------------------------------------------------------------------------------------------------------------------


--Delete unused columns


SELECT *
FROM portfolioProject..NashvilleHousing;

ALTER TABLE portfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
