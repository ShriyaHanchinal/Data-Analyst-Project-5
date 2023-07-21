/*Cleaning Data in SQL queries*/

Select * from DataCleaning.dbo.NashvilleHousing


----------- Standardize Date Format -----------

Alter Table DataCleaning.dbo.NashvilleHousing
Add SaleDateConverted date;

Update DataCleaning.dbo.NashvilleHousing
Set SaleDateConverted = convert(date, SaleDate)


----------- Populate Property Address data -----------

Update a
Set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaning.dbo.NashvilleHousing a
Join DataCleaning.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is Null


----------- Breaking out Address into Individual columns(Address, City, State) -----------

Alter Table DataCleaning.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255), PropertySplitCity nvarchar(255);

Update DataCleaning.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))


Alter Table DataCleaning.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255), OwnerSplitCity nvarchar(255), OwnerSplitState nvarchar(255);

Update DataCleaning.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


----------  Change Y and N to Yes and No in SoldAsVacant column -----------

Update DataCleaning.dbo.NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
						When SoldAsVacant = 'N' then 'No'
				   Else SoldAsVacant
				   END


----------- Removing Duplicate values -----------

With RowNumCTE as
(
Select *, ROW_NUMBER() Over(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference Order By UniqueID) as row_num 
from DataCleaning.dbo.NashvilleHousing
) 

Delete from RowNumCTE
Where row_num > 1


----------- Deleting Unused data -----------

Alter Table DataCleaning.dbo.NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

