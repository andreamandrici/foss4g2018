#!/bin/bash

# SET SOME VARIABLES
SQL="./sql"
dpath="/media/user/usbdata/foss4g/DATA"
dbpar="host=localhost user=user dbname=foss4g"

# DROP THE DB IF EXISTS
dropdb --if-exists foss4g

# WAIT FOR THE PREVIOUS COMMAND TO END BEFORE STARTING THE NEXT
wait

# CREATE THE DB
psql -c "CREATE DATABASE foss4g;"

# INSTALL POSTGIS EXTENSION
psql -d "foss4g" -c "CREATE EXTENSION postgis;"

# IMPORT VECTORS

###			ogr2ogr parameters used
### -overwrite				delete the output layer if exists and recreate it empty 					
### -dialect sqlite			use sqlite SQL dialect				
### -sql					SQL statement to execute			
### -f						format_name				
### -lco					Layer creation option (format specific)
	###	FID						name of the PK column to create
### -nlt					define the geometry type for the created layer
### -nln					Assign a name to the new layer	

## IMPORT COUNTRIES

### IMPORT LAND
ogr2ogr \
-overwrite \
-dialect sqlite \
-sql "SELECT ADM0_CODE, ADM0_NAME, Geometry FROM country_land" \
-f "PostgreSQL"  PG:"$dbpar" $dpath/Countries/country_land.shp \
-lco FID=ADM0_CODE \
-nlt "MULTIPOLYGON" \
-nln country_land

### IMPORT MARINE
ogr2ogr \
-overwrite \
-dialect sqlite \
-sql "SELECT MRGID, GeoName, Geometry FROM country_marine" \
-f "PostgreSQL" PG:"$dbpar" $dpath/Countries/country_marine.shp \
-lco FID=MRGID \
-nlt "MULTIPOLYGON" \
-nln country_marine

### IMPORT DISSOLVED

ogr2ogr \
-overwrite \
-dialect sqlite \
-sql "SELECT country_id, country_na AS country_name, Geometry FROM country_dissolved" \
-f "PostgreSQL" PG:"$dbpar" $dpath/Countries/country_dissolved.shp \
-lco FID=country_id \
-nlt "MULTIPOLYGON" \
-nln country_dissolved

## IMPORT PROTECTED AREAS

ogr2ogr \
-overwrite \
-dialect sqlite \
-sql "SELECT * FROM protected_areas" \
-f "PostgreSQL" PG:"$dbpar" $dpath/ProtectedAreas/protected_areas.shp \
-lco FID=wdpaid \
-nlt "MULTIPOLYGON" \
-nln protected_areas

## IMPORT SPECIES

ogr2ogr \
-overwrite \
-dialect sqlite \
-sql "SELECT * FROM species" \
-f "PostgreSQL" PG:"$dbpar" $dpath/Species/species.shp \
-lco FID=id_no \
-nlt "MULTIPOLYGON" \
-nln species

## EXECUTE EXTERNAL SQL CODE FROM BASH SCRIPT

### rename some field
psql -d foss4g -f ${SQL}/sl01_rename_geometry.sql;

### CREATE A NEW ATTRIBUTE TABLE FOR LANDCOVER
psql -d foss4g -f ${SQL}/sl02_landcover.sql;

wait

### IMPORT A CSV FILE INTO NEW CREATED TABLE

echo "\copy lc_attributes FROM ${dpath}/Landcover/landcover_attributes.csv delimiter '|' csv;" | psql -d foss4g;

# IMPORT RASTERS

###			raster2pgsql parameters used
### -I							create a GIST indexon the raster column
### -C							apply RASTER constraints: SRID, pixelsize, etc: to ensure RASTER is properly registered in raster_columns view
### -e							execute each statement individually, do not use a transaction
### -Y							use COPY statements instead of insert statements (quicker)
### -s <SRID>					assign a specific SRID to the output RASTER
### -t <WIDTHxHEIGHT>			cut RASTER in tiles, inserted one per table row
### -l	<2,4,n...>				create overviews (only for QGIS) with assigned factors, comma sparated		

## IMPORT DEM	 	

raster2pgsql -I -C -e -Y -s 4326 -t 512x512 -l 2,4,8,16 \
$dpath/DEM/dem.tif dem \
| psql -d foss4g

## IMPORT LANDCOVER

### IMPORT LANDCOVER 1995 (from tif), building overviews

raster2pgsql -I -C -e -Y -s 4326 -t 512x512 -l 2,4,8,16 \
$dpath/Landcover/landcover_1995.tif lc1995 \
| psql -d foss4g


### IMPORT LANDCOVER 2015 (from tif), building overviews

raster2pgsql -I -C -e -Y -s 4326 -t 512x512 -l 2,4,8,16 \
$dpath/Landcover/landcover_2015.tif lc2015 \
| psql -d foss4g

### IMPORT LANDCOVER 1995 AND 2015 into two different bands (from vrt), without building overviews

raster2pgsql -I -C -e -Y -s 4326 -t 512x512 \
$dpath/Landcover/lc_1995_2015.vrt lc_1995_2015 \
| psql -d foss4g
