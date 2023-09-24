Select *
From [PortfolioProject ].dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------
--Standardize date format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From [PortfolioProject ].dbo.Nashvillehousing

Update [PortfolioProject ].dbo.Nashvillehousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [PortfolioProject ].dbo.Nashvillehousing
ADD SaleDateConverted Date;

Update [PortfolioProject ].dbo.Nashvillehousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-----------------------------------------------------------------------------------------------
-- Populate Property Address Data

Select *
From [PortfolioProject ].dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID 

-- to make the if this one parcel id have an idress let populate it with an anothe that has an adresss. so we will do a self join

Select a.ParcelID, A.PropertyAddress, b.ParcelID, b.PropertyAddress
From [PortfolioProject ].dbo.NashvilleHousing a
JOIN [PortfolioProject ].dbo.NashvilleHousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [PortfolioProject ].dbo.NashvilleHousing a
JOIN [PortfolioProject ].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------
--Breaking Out Address into individual columns (Address, City, State)

Select PropertyAddress
From [PortfolioProject ].dbo.NashvilleHousing 
--Where Propertyaddress is null
--order by ParcelID


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) As Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From [PortfolioProject ].dbo.NashvilleHousing 

From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE [PortfolioProject ].dbo.Nashvillehousing
Add PropertySplitAddress Nvarchar(255);

Update [PortfolioProject ].dbo.Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE [PortfolioProject ].dbo.Nashvillehousing 
Add PropertySplitCity Nvarchar(255);

Update [PortfolioProject ].dbo.Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

Select *
From [PortfolioProject ].dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------
---Using Parsename to split columns

Select OwnerAddress
From [PortfolioProject ].dbo.NashvilleHousing

Select
PARSENAME (REPLACE(OwnerAddress,',','.'),3)
,PARSENAME (REPLACE(OwnerAddress,',','.'),2)
,PARSENAME (REPLACE(OwnerAddress,',','.'),1)
From [PortfolioProject ].dbo.NashvilleHousing



ALTER TABLE [PortfolioProject ].dbo.Nashvillehousing
Add OwnerSplitAddress Nvarchar(255);

Update [PortfolioProject ].dbo.Nashvillehousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [PortfolioProject ].dbo.Nashvillehousing 
Add OwnerSplitCity Nvarchar(255);

Update [PortfolioProject ].dbo.Nashvillehousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [PortfolioProject ].dbo.Nashvillehousing 
Add OwnerSplitState Nvarchar(255);

Update [PortfolioProject ].dbo.Nashvillehousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress,',','.'),1)


Select*
From [PortfolioProject ].dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "sold as Vacant" field 


Select Distinct(Soldasvacant), count(Soldasvacant)
From [PortfolioProject ].dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
From [PortfolioProject ].dbo.NashvilleHousing
h


UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
From [PortfolioProject ].dbo.NashvilleHousing

/* Always remember to after creating a CASE you need to UPDATE before 
running DISTINCT AGAIN to be sure all has been updated and captured*/


----------------------------------------------------------------------------------------------
---REMOVE DUPLICATES

/*Before removing a duplicate we will have to run a CTES*/


WITH RowNumCTE AS(
Select*,
	ROW_number()over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
	
From [PortfolioProject ].dbo.NashvilleHousing
--order by ParcelID

)
Select *
From RowNumCTE
where row_num > 1
order by PropertyAddress

--- the above will bring out all the total infomation with duplicates inside our data sets with thier corresponding number then we do the following below to delete the duplicates and check again 


WITH RowNumCTE AS(
Select*,
	ROW_number()over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
	
From [PortfolioProject ].dbo.NashvilleHousing
--order by ParcelID

)
Delete
From RowNumCTE
where row_num > 1

-------after duplicates have been removed we check again if there is an uncaptured duplicates in our data
WITH RowNumCTE AS(
Select*,
	ROW_number()over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
	
From [PortfolioProject ].dbo.NashvilleHousing
--order by ParcelID

)
Select *
From RowNumCTE
where row_num > 1
order by PropertyAddress


--Best practice dont delete datas instead do a CTE'S

-----------------------------------------------deleting unused coolumns

Select *
From [PortfolioProject ].dbo.NashvilleHousing

ALTER TABLE [PortfolioProject ].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [PortfolioProject ].dbo.NashvilleHousing
DROP COLUMN Saledate