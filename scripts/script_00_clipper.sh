#!/bin/bash

# SET SOME VARIABLES
dpath="../DATA"

# CLIP RASTERS

## CLIP DEM

gdalwarp \
-cutline \
$dpath/DEM/aoi_dem_cutter.shp \
-crop_to_cutline \
-co "TILED=YES" -co BLOCKXSIZE=256 -co BLOCKYSIZE=256 \
-co "COMPRESS=LZW" \
$dpath/DEM/GEBCO2014_0.0_-90.0_90.0_0.0_30Sec_Geotiff.tif \
$dpath/DEM/dem.tif

## CLIP Landcover

### CLIP EPOCH 1995

# gdalwarp \
# -cutline \
# $dpath/Landcover/aoi_lc_cutter.shp \
# -crop_to_cutline \
# -co "TILED=YES" -co BLOCKXSIZE=256 -co BLOCKYSIZE=256 \
# -co "COMPRESS=LZW" \
# $dpath/Landcover/ESACCI-LC-L4-LCCS-Map-300m-P1Y-1995-v2.0.7.tif \
# $dpath/Landcover/landcover_1995.tif

### CLIP EPOCH 2015

# gdalwarp \
# -cutline \
# $dpath/Landcover/aoi_lc_cutter.shp \
# -crop_to_cutline \
# -co "TILED=YES" -co BLOCKXSIZE=256 -co BLOCKYSIZE=256 \
# -co "COMPRESS=LZW" \
# $dpath/Landcover/ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7.tif \
# $dpath/Landcover/landcover_2015.tif

