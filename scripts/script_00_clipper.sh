#!/bin/bash

# SET SOME VARIABLES
dpath="../DATA"


echo "

This script will create the needed datasets in specific subfolders of DATA

"

# CREATE RASTERS

echo "

CREATING RASTERS

"


## CLIP DEM

echo "

	CREATING DEM

"

echo "

		clipping DEM

"

gdalwarp \
-overwrite \
-cutline \
$dpath/original_datasets/cutters/aoi_dem_cutter.shp \
-crop_to_cutline \
-co "TILED=YES" -co BLOCKXSIZE=256 -co BLOCKYSIZE=256 \
-co "COMPRESS=LZW" \
$dpath/original_datasets/gebco.tif \
$dpath/DEM/dem.tif \

## CLIP Landcover

echo "

	CREATING LANDCOVER

"

### CLIP EPOCH 1995

echo "

		clipping 1995 Landcover

"

gdalwarp \
-overwrite \
-cutline \
$dpath/original_datasets/cutters/aoi_lc_cutter.shp \
-crop_to_cutline \
-co "TILED=YES" -co BLOCKXSIZE=256 -co BLOCKYSIZE=256 \
-co "COMPRESS=LZW" \
$dpath/original_datasets/ESACCI-LC-L4-LCCS-Map-300m-P1Y-1995-v2.0.7.tif \
$dpath/Landcover/landcover_1995.tif

### CLIP EPOCH 2015

echo "

		clipping 2015 Landcover

"

gdalwarp \
-overwrite \
-cutline \
$dpath/original_datasets/cutters/aoi_lc_cutter.shp \
-crop_to_cutline \
-co "TILED=YES" -co BLOCKXSIZE=256 -co BLOCKYSIZE=256 \
-co "COMPRESS=LZW" \
$dpath/original_datasets/ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7.tif \
$dpath/Landcover/landcover_2015.tif

# CREATE VECTORS

echo "

creating VECTORS

"

## CREATE PROTECTED AREAS

echo "

	CREATING PROTECTED AREAS

"

ogr2ogr \
-overwrite \
-dialect sqlite \
-sql "SELECT 
CAST(WDPAID AS Integer64) AS wdpaid,
NAME as name,
DESIG_ENG AS desig_eng,
DESIG_TYPE AS desig_type,
IUCN_CAT AS iucn_cat,
INT_CRIT AS int_crit,
CAST(MARINE AS Integer64) AS marine,
ISO3 AS iso3,
GIS_AREA AS area_geo,
Geometry FROM wdpa" \
$dpath/ProtectedAreas/protected_areas.shp \
/vsizip/$dpath/original_datasets/wdpa.zip \
-lco RESIZE=YES

## CREATE COUNTRIES

echo "

	CREATING COUNTRIES
	
"



### CREATE COUNTRY_LAND

echo "

		creating country land

"


ogr2ogr \
-overwrite \
-dialect sqlite \
-sql "SELECT GID_0 ADM0_CODE, NAME_0 ADM0_NAME, Geometry FROM gadm36_TZA_0" \
$dpath/Countries/country_land.shp \
/vsizip/$dpath/original_datasets/gadm36_TZA_shp.zip/gadm36_TZA_0.shp

### CREATE COUNTRY_MARINE

echo "

		creating country marine

"

ogr2ogr \
-overwrite \
$dpath/Countries/country_marine.shp \
/vsizip/$dpath/original_datasets/eez.zip/eez.shp

wait

### CREATE COUNTRY DISSOLVED

echo "

		creating country dissolved

"


ogr2ogr \
-overwrite \
-dialect sqlite \
-sql "SELECT ADM0_CODE, Geometry FROM country_land" \
$dpath/Countries/country_dissolved1.shp \
$dpath/Countries/country_land.shp

wait

ogr2ogr \
-update \
-append \
-dialect sqlite \
-sql "SELECT iso_ter1 ADM0_CODE, Geometry FROM country_marine" \
$dpath/Countries/country_dissolved1.shp \
$dpath/Countries/country_marine.shp

wait

ogr2ogr \
-overwrite \
$dpath/Countries/country_dissolved.shp \
$dpath/Countries/country_dissolved1.shp \
-dialect sqlite \
-sql "SELECT ADM0_CODE, ST_UNION(ST_BUFFER(Geometry,0.001)) FROM country_dissolved1 GROUP BY ADM0_CODE"

wait

rm $dpath/Countries/country_dissolved1.*

### CREATE AOI

echo "

		creating country extent

"


ogr2ogr \
-overwrite \
$dpath/Countries/country_extent.shp \
$dpath/Countries/country_dissolved.shp \
-dialect sqlite \
-sql "SELECT ADM0_CODE, ST_ENVELOPE(Geometry) FROM country_dissolved"

### CREATE SPECIES

echo "

	CREATING SPECIES
	
"

echo "

		clipping cheetah

"


ogr2ogr \
-overwrite \
-clipsrc $dpath/Countries/country_extent.shp \
$dpath/Species/merge.shp \
/vsizip/$dpath/original_datasets/species_219.zip/species_219 \
-dialect sqlite \
-sql "SELECT id_no,Geometry FROM species_219 WHERE presence IN (1,2) AND origin IN (1,2)"

echo "

		clipping dugong

"

ogr2ogr \
-update \
-append \
-clipsrc $dpath/Countries/country_extent.shp \
$dpath/Species/merge.shp \
/vsizip/$dpath/original_datasets/species_6909.zip/species_6909 \
-dialect sqlite \
-sql "SELECT id_no,Geometry,0.001 FROM species_6909 WHERE presence IN (1,2) AND origin IN (1,2)"

echo "

		clipping giraffe

"

ogr2ogr \
-update \
-append \
-clipsrc $dpath/Countries/country_extent.shp \
$dpath/Species/merge.shp \
/vsizip/$dpath/original_datasets/species_9194.zip/species_9194 \
-dialect sqlite \
-sql "SELECT id_no,Geometry FROM species_9194 WHERE presence IN (1,2) AND origin IN (1,2)"

echo "

		clipping elephant

"

ogr2ogr \
-update \
-append \
-clipsrc $dpath/Countries/country_extent.shp \
$dpath/Species/merge.shp \
/vsizip/$dpath/original_datasets/species_12392.zip/species_12392 \
-dialect sqlite \
-sql "SELECT id_no,Geometry FROM species_12392 WHERE presence IN (1,2) AND origin IN (1,2)"

echo "

		clipping whale shark

"

ogr2ogr \
-update \
-append \
-clipsrc $dpath/Countries/country_extent.shp \
$dpath/Species/merge.shp \
/vsizip/$dpath/original_datasets/species_19488.zip/species_19488 \
-dialect sqlite \
-sql "SELECT id_no,Geometry FROM species_19488 WHERE presence IN (1,2) AND origin IN (1,2)"

echo "

		merging all species

"

ogr2ogr \
-overwrite \
$dpath/Species/merge2.shp \
$dpath/Species/merge.shp \
-dialect sqlite \
-sql "SELECT id_no,ST_UNION(ST_BUFFER(Geometry,0.001)) FROM merge GROUP BY id_no"

echo "

		joining species attributes

"

ogr2ogr \
-overwrite \
$dpath/Species/species.shp \
$dpath/Species/merge2.shp \
-dialect sqlite \
-sql "SELECT a.*,b.* FROM merge2 a LEFT JOIN '$dpath/Species/species_attributes.csv'.species_attributes b ON a.id_no = b.id_no"

rm $dpath/Species/merge*

echo "

ALL DATASETS READY

"

