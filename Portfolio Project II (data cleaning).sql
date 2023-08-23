-- CLEANING DATA FOR SQL QUERY

SELECT 
	*
FROM
	portfolioproject1..NashvilleHousing

-- STANDARDIZING DATE FORMAT

SELECT 
	SaleDateConverted,
CAST
	(SaleDate AS date) AS SaleDateNew
FROM
	portfolioproject1..NashvilleHousing

UPDATE 
	NashvilleHousing
SET 
	SaleDateConverted = CAST(SaleDate AS date)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

-- POPULATE PROPERTY ADDRESS DATA 
SELECT 
	a.PropertyAddress, 
	a.parcelID, 
	b.PropertyAddress, 
	b.ParcelID, 
ISNULL
	(a.PropertyAddress, b.PropertyAddress)
FROM
	portfolioproject1..NashvilleHousing a
JOIN
	portfolioproject1..NashvilleHousing b
ON 
	a.ParcelID = b.ParcelID
AND 
	a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress IS NULL 

UPDATE a
SET 
	PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	portfolioproject1..NashvilleHousing a

JOIN
	portfolioproject1..NashvilleHousing b
ON 
	a.ParcelID = b.ParcelID
AND 
	a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress IS NULL 

--SEPERATING THE PROPERTY ADDRESS TO DIFFERENT COLUMNS I.E. [ADDRESS, CITY, STATE].

SELECT 
	PropertyAddress
FROM
	portfolioproject1..NashvilleHousing
--ORDER BY 
--	ParcelID

SELECT
	SUBSTRING
	(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
AS	ADDRESS,
	SUBSTRING
	(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
AS	ADDRESS_CITY
FROM
	portfolioproject1..NashvilleHousing

ALTER TABLE
	portfolioproject1..NashvilleHousing
ADD 
	PropertySplitAddress NVARCHAR(255);

UPDATE 
	portfolioproject1..NashvilleHousing
SET 
	PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE
	portfolioproject1..NashvilleHousing
ADD 
	PropertySplitCity NVARCHAR(255);

UPDATE 
	portfolioproject1..NashvilleHousing
SET 
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--PREVIEWING CHANGES

SELECT *
FROM
	portfolioproject1..NashvilleHousing

--SPLITTING THE OWNER_ADDRESS COLUMN TO ADDRESS, STATE AND CITY

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM
	portfolioproject1..NashvilleHousing


	--FOR ADDRRESS;
ALTER TABLE
	portfolioproject1..NashvilleHousing
ADD 
	OwnerSplitAddress NVARCHAR(255);

	--FOR CITY;
ALTER TABLE
	portfolioproject1..NashvilleHousing
ADD 
	OwnerSplitCity NVARCHAR(255);

	--FOR STATE;
ALTER TABLE
	portfolioproject1..NashvilleHousing
ADD 
	OwnerSplitState NVARCHAR(255);

UPDATE 
	portfolioproject1..NashvilleHousing
SET 
	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE 
	portfolioproject1..NashvilleHousing
SET 
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE 
	portfolioproject1..NashvilleHousing
SET 
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- CHANGING Y AND N TO YES AND NO IN THE SOLDASVACANT COLUMN;

SELECT
	SoldAsVacant,
CASE
	WHEN 
		SoldAsVacant = 'Y' THEN 'Yes'
	WHEN 
		SoldAsVacant = 'N' THEN 'No'
	ELSE
		SoldAsVacant
	END
AS
	SoldAsVacantFIXED
FROM
	portfolioproject1..NashvilleHousing

UPDATE
	portfolioproject1..NashvilleHousing
SET 
	SoldAsVacant = CASE
	WHEN 
		SoldAsVacant = 'Y' THEN 'Yes'
	WHEN 
		SoldAsVacant = 'N' THEN 'No'
	ELSE
		SoldAsVacant
	END

	--PREVIEWING CHANGES
SELECT
	DISTINCT SoldAsVacant, 
	COUNT(SoldAsVacant)
FROM
	portfolioproject1..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--REMOVING DUPLICATES 

WITH 
	ROW_NUM_CTE AS 
	(
SELECT *,
	ROW_NUMBER() 
	OVER	(
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
						UniqueID
			)		
					AS
						ROW_NUM

FROM
	portfolioproject1..NashvilleHousing
	)

DELETE 
FROM
	ROW_NUM_CTE
WHERE
	ROW_NUM > 1


-- DELETING UNUSED COLUMNS

SELECT *
FROM
	portfolioproject1..NashvilleHousing

ALTER TABLE
	portfolioproject1..NashvilleHousing
DROP COLUMN
	OwnerAddress,
	TaxDistrict,
	PropertyAddress,
	SaleDate