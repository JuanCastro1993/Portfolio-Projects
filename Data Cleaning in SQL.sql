
---Cleaning Data in SQL Queries

select *
from PortafolioProject.dbo.NashvilleHousing



----Standarize Date Format

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortafolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing 
SET SaleDate = CONVERT(Date,SaleDate)

--Modificando la tabla para poder ver los registros de Nuevos a los que haremos Queries.

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(Date,SaleDate)

----Populate Property Address Data

select *
from PortafolioProject.dbo.NashvilleHousing
--where PropertyAddress is Null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,  b.PropertyAddress)
from PortafolioProject.dbo.NashvilleHousing a
JOIN PortafolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,  b.PropertyAddress)
from PortafolioProject.dbo.NashvilleHousing a
JOIN PortafolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null


---- Breaking Out Address into a Diferent Columns (Address, City, State)

select PropertyAddress
from PortafolioProject.dbo.NashvilleHousing

---Removing the comma
Select 
SUBSTRING(PropertyAddress, -1, CHARINDEX(',',PropertyAddress)) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN (PropertyAddress)) as Address
	
from PortafolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar (255); 

--Updating the tables

UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, -1, CHARINDEX(',',PropertyAddress))


ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar (255); 

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN (PropertyAddress))

---Selecting the Table to verify if the query made was perfectly working.

select *
from PortafolioProject.dbo.NashvilleHousing

---Splitting the Owner Address (PARSENAME---REPLACE)

select OwnerAddress
from PortafolioProject.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',' , '.'),3),
PARSENAME(REPLACE(OwnerAddress,',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress,',' , '.'),1)
from PortafolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar (255); 

UPDATE NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',' , '.'),3)


ALTER TABLE NashvilleHousing
Add OwenerSplitCity nvarchar (255); 

UPDATE NashvilleHousing 
SET OwenerSplitCity = PARSENAME(REPLACE(OwnerAddress,',' , '.'),2)


ALTER TABLE NashvilleHousing
Add OwenerSplitState nvarchar (255); 

UPDATE NashvilleHousing 
SET OwenerSplitState = PARSENAME(REPLACE(OwnerAddress,',' , '.'),1)

select *
from PortafolioProject.dbo.NashvilleHousing

---Changing Y to "Yes" and N to "NO"

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortafolioProject.dbo.NashvilleHousing
Group by SoldAsVacant

---Using Case

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' then 'YES'
	     When SoldAsVacant = 'N' then 'NO'
ELSE
	SoldAsVacant
END
from PortafolioProject.dbo.NashvilleHousing

--Updating Table Using Case

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE When SoldAsVacant = 'Y' then 'YES'
	     When SoldAsVacant = 'N' then 'NO'
ELSE
	SoldAsVacant
END
from PortafolioProject.dbo.NashvilleHousing

------ Checking the compatibility database, due to an error it was showing.

select name,compatibility_level from sys.databases;

----Removing Duplicates

WITH RowNumCTE
as
(
Select *,
   ROW_NUMBER() 
   OVER(PARTITION BY ParcelID ORDER BY UniqueID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				) row_num

from PortafolioProject.dbo.NashvilleHousing
)
---Eliminamos con el comando DELETE, los datos que estaban duplicados, luego verificamos nuevamente que no habian datos duplicados.
Select*
from RowNumCTE
where row_num >1
Order by PropertyAddress

---Confirmando que los datos no se borraron por completo, y que solo nos quedo la data Integra.
Select *
from PortafolioProject.dbo.NashvilleHousing

-----Ahora eliminaremos las columnas que no necesitamos para nuestro ejercicio.
----Eliminaremos las Columnas que le hicimos Split anteriormente y en adicion a esto (OwnerAddress, TaxDistrict,PropertyAddress and SaleDate)

Select *
from PortafolioProject.dbo.NashvilleHousing

ALTER TABLE PortafolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE PortafolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate