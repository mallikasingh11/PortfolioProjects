/*

Cleaning Data in SQL Queries

*/

SELECT * FROM PortfolioProject.nashvillehousing;

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(SaleDate, Date)
FROM PortfolioProject.nashvillehousing;

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE PortfolioProject.nashvillehousing
Add SaleDateConverted Date;

Update PortfolioProject.nashvillehousing
SET SaleDateConverted = CONVERT(SaleDate, Date);

-- Populate Property Address Data

SELECT * FROM PortfolioProject.nashvillehousing
-- WHERE PropertyAddress is null
order by ParcelID;

-- IFNULL instead of ISNULL in MySQL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.nashvillehousing a
JOIN PortfolioProject.nashvillehousing b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

Update PortfolioProject.nashvillehousing a
JOIN PortfolioProject.nashvillehousing b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress is null;

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress from PortfolioProject.nashvillehousing;

-- LOCATE instead of CHARINDEX in MySQL

-- -1 removes the comma at the end of the address, +1 removes the comma at the start of the town

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress)) as Address
FROM PortfolioProject.nashvillehousing;

ALTER TABLE PortfolioProject.nashvillehousing
ADD PropertySplitAddress varchar(50);

Update PortfolioProject.nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1);

ALTER TABLE PortfolioProject.nashvillehousing
Add PropertySplitCity varchar(50);

Update PortfolioProject.nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress));

SELECT * FROM PortfolioProject.nashvillehousing;

-- OWNER ADDRESS

SELECT OwnerAddress FROM PortfolioProject.nashvillehousing;

SELECT
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1),',',-1) as street,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',',-1) as city,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3),',',-1) as state
FROM PortfolioProject.nashvillehousing;


ALTER TABLE PortfolioProject.nashvillehousing
ADD OwnerSplitAddress varchar(50);

Update PortfolioProject.nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1),',',-1);

ALTER TABLE PortfolioProject.nashvillehousing
ADD OwnerSplitCity varchar(50);

Update PortfolioProject.nashvillehousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',',-1);

ALTER TABLE PortfolioProject.nashvillehousing
ADD OwnerSplitState varchar(50);

Update PortfolioProject.nashvillehousing
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3),',',-1);

SELECT * from PortfolioProject.nashvillehousing;

-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT distinct(SoldasVacant), count(SoldAsVacant)
FROM PortfolioProject.nashvillehousing
Group by SoldasVacant
Order by 2;

SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.nashvillehousing;


Update PortfolioProject.nashvillehousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;
    
SELECT * from PortfolioProject.nashvillehousing;

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, 
										  PropertyAddress,
                                          SaleDate,
                                          LegalReference
                                          ORDER BY UniqueID) as row_num
                                          FROM PortfolioProject.nashvillehousing)
-- Checking if it worked, need to run it with the CTE
SELECT * FROM RowNumCTE
WHERE row_num > 1;

-- Cannot delete from CTE in MySQL, need to join on original table to delete
DELETE FROM PortfolioProject.nashvillehousing using PortfolioProject.nashvillehousing JOIN RowNumCTE
on PortfolioProject.nashvillehousing.UniqueID = RowNumCTE.UniqueID where row_num >1;

-- Returning 104 less rows meaning duplicates have been removed
SELECT * from PortfolioProject.nashvillehousing;

-- Delete Unused Columns
SELECT * 
FROM PortfolioProject.nashvillehousing;

ALTER TABLE PortfolioProject.nashvillehousing
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress, 
DROP COLUMN TaxDistrict;

ALTER TABLE PortfolioProject.nashvillehousing
DROP COLUMN SaleDate;


-- FINAL CLEANED DATASET

SELECT * from PortfolioProject.nashvillehousing;