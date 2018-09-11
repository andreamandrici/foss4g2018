# foss4g2018 -- THIS REPO IS WORK IN PROGRESS -- PLEASE COME BACK NEXT WEEK!
## Free and Open Source Geospatial Tools for Conservation Planning Workshop - FOSS4G 2018 - Dar Es Salaam

Step by step documentation for developing GIS processing and publish results through Restfull APIs 
_____________________________________________________________________________________

## Intro

We will be taking a tour and in-depth look at the workflow used by the DOPA-BIOPAMA team to process and
publish a series of global indicators on protected areas, available through our [DOPA Explorer interface](https://dopa-explorer.jrc.ec.europa.eu/).
In the [BIOPAMA project](http://rris.biopama.org/), where we focus in more detail on 79 African, Caribbean, Pacific countries, we have filtered/re-processed these, for example to recalculate the rankings of some indicators since we are working on a subset of countries.

Although this is a specific workflow for protected areas, we face general geoprocessing challenges due to the size and complexity of the input datasets (eg: more than 250000 protected areas, more than 70000 animal species considered), and the many relationships within them (eg: circa 7500000 intersections within protected areas and species polygons), resulting in a large number of indicators derived from the input datasets.

To solve these problems, over time we have identified a sequence of actions (which uses only Open Source software) which are optimized to achieve the goal in the best way, and in the shortest possible time. Through our workshop, we hope to present and discuss this workflow and how we got there, not only because other people face the same challenges, but because we may also be able to improve even further with your input. We believe in transparently publishing not only these indicators, but also the methodology used and what is really behind the numbers. These numbers are important, as they are helping inform major policy decisions affecting some of the most important biodiversity areas of the planet.

For obvious reasons of time and resources (some of our processing scripts take days to execute, using a 40 cores server: we will have only 4 hours available, and desktops), we will present a sample of the above sequence, on datasets clipped to Tanzania, our host country for the workshop.

<p style='text-align: right;'> <b>Andrea Mandrici, Luca Battistella & Steve Peedell</b> </p> 

## About the system:

Workshop will be carried out totally offline using [OSGEO LIVE 11.0 Linux distribution](https://live.osgeo.org/en/index.html).

Please have a look at:

*  https://live.osgeo.org/en/quickstart/usb_quickstart.html
*  https://live.osgeo.org/en/quickstart/internationalisation_quickstart.html

We setup our:

*  8 GB flash key
*  using [mkusb](https://launchpad.net/~mkusb/+archive/ubuntu/ppa)
*  under [Ubuntu Mate 16.04](http://cdimage.ubuntu.com/ubuntu-mate/releases/16.04.5/release/ubuntu-mate-16.04.5-desktop-amd64.iso)
*  from [OSGEO Live VERSION 11.0 amd-64 image](https://sourceforge.net/projects/osgeo-live/files/11.0/osgeo-live-11.0-amd64.iso/download)
*  with 75% of space to persistence, and the other 25% to secondary ntfs partition.

After your Osgeo Live flash key is ready (but not booted):

*  mount the Osgeo Live flash key as external disk on your usual OS
*  download [this](https://github.com/andreamandrici/foss4g2018) repository, unzip it in the ntfs "usbdata" partition of the flash key, and rename it as "foss4g"  (/usbdata/foss4g2018-master/ --> /usbdata/foss4g/)

If you use another path (eg: home folder: "/home/user/" on Osgeo Live) or folder name, you will need to change by yourself a lot of path variables accordingly!

To do the workshop on Osgeo Live completely offline, you will also need:

*  [geany](http://archive.ubuntu.com/ubuntu/pool/universe/g/geany/geany_1.27-1_amd64.deb)
*  [geany-common](http://archive.ubuntu.com/ubuntu/pool/universe/g/geany/geany-common_1.27-1_all.deb)

Please download the above packages, and copy them in /usbdata/foss4g/packages/ folder of the Osgeo Live flash key.

## About data:

Participants are requested to download their own copies of data which are going to be used during the workshop (we are not authorised to redistribute some of these datasets ourselves).

The following links may require registration:

1.  [GADM](https://gadm.org/) (please note: we currently use [FAO GAUL data](http://www.fao.org/geonetwork/srv/en/metadata.show?id=12691), but GADM is open):
    *  [Tanzania Admin Areas](https://biogeo.ucdavis.edu/data/gadm3.6/shp/gadm36_TZA_shp.zip)
2.  [Marine Regions EEZ](http://www.marineregions.org/):
    *  [Tanzania EEZ](http://geo.vliz.be/geoserver/wfs?request=getfeature&service=wfs&version=1.0.0&typename=MarineRegions:eez&outputformat=SHAPE-ZIP&filter=%3CPropertyIsEqualTo%3E%3CPropertyName%3Emrgid%3C%2FPropertyName%3E%3CLiteral%3E8479%3C%2FLiteral%3E%3C%2FPropertyIsEqualTo%3E)
3.  [UNEP-WCMC WDPA](https://www.protectedplanet.net):
	  *  [WDPA current](http://wcmc.io/wdpa_current_release)
	
	  Extract the \*.gdb file from the downloaded zip and rename it as "wdpa.gdb", then delete the zip archive.
4.  [ESA CCI LC](https://www.esa-landcover-cci.org/):
    * ftp://geo10.elie.ucl.ac.be/v207/ESACCI-LC-L4-LCCS-Map-300m-P1Y-1995-v2.0.7.tif
    * ftp://geo10.elie.ucl.ac.be/v207/ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7.tif
5.  [IUCN Redlist](http://www.iucnredlist.org):
    *	[Cheetah](http://www.iucnredlist.org/download_spatial_data/species_219)
    *	[Dugong](http://www.iucnredlist.org/download_spatial_data/species_6909)
    *	[Giraffe](http://www.iucnredlist.org/download_spatial_data/species_9194)
    *	[African Elephant](http://www.iucnredlist.org/download_spatial_data/species_12392)
    *	[Whale Shark](http://www.iucnredlist.org/download_spatial_data/species_19488)
6.  [GEBCO terrain model](https://www.gebco.net):
    *	[2014 30 arc-second grid](https://www.gebco.net/data_and_products/gridded_bathymetry_data), providing the following parameters on "Select your data set" section:
        *  Search Box Coordinates = "29,-12,44,0"
        *  "GEBCO_2014 Grid (30 arc-second interval)"
        *  "User-defined area - INT16 GeoTIFF (data)".
  
    Extract the \*.tif file from the downloaded zip and rename it as "gebco.tif", then delete the zip archive.

Please copy downloaded and renamed datasets in /usbdata/foss4g/DATA/original_datasets folder.
At the end of the process, this folder should contain:

*  eez.zip
*  ESACCI-LC-L4-LCCS-Map-300m-P1Y-1995-v2.0.7.tif
*  ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7.tif
*  gadm36_TZA_shp.zip
*  gebco.tif
*  species_219.zip
*  species_6909.zip
*  species_9194.zip
*  species_12392.zip
*  species_19488.zip                                 
*  wdpa.gdb

Since the above files will be deleted during the next steps, we suggest to keep a copy of them on another partition (space on the flash key is not limitless).

## Setup your system

Boot with your external flash key.

Install a decent editor:

### offline

Be sure to have correctly downloaded geany_\*.deb packages from the "About the system" section

```
*  Launch LXTerminal
*  cd /media/user/usbdata/foss4g/scripts/			
*  ./script_01_install_geany.sh
```

### online

you need to connect to internet before; since unreliability of network in Tanzania, we suggest to not do it.

`*  sudo apt-get install geany`

Password is "user".

if needed, setup your keyboard

`*  ./script_02_reconfigure_keyboard.sh`

_____________________________________________________________________________________

## Desktop OS GIS tools

### Viewing selected datasets cut on Tanzania
(QGIS)

From Qgis Browser Panel

`*  add folder /media/user/usbdata/foss4g/DATA to Favourites`

Explore datasets

* Countries: terrestrial and marine boundaries (vector)
* Protected areas (vector)
* Land Cover (raster, discrete)
  *  have a look at the Virtual Raster
* Topography and Bathimetry (raster, continuous)
* Species (vector)

###  Simple questions

*  Which (endangered) animals are present in this protected area?
*  What is the landscape (mountains? higlands? sea-level?) of this protected area?
*  How is the natural vegetation status (and evolution trend) in this protected area? 

###  Simple Desktop analysis on sample dataset (QGIS)

1.  Basic intersection of vector objects (Spatial Query Plugin)

    Load protected_areas and species  
  
    ```	
    *  activate spatial query plugin
    *  select a protected area
    *  find intersecting species 
    ```

2.  Zonal Statistics (ZS) on continuous raster (Processing Toolbox Algorithms: PTA)

    Load country_dissolved, protected_areas and DEM  
   
    ```
    *  PTA ZS on country area+DEM
    *  PTA ZS on protected areas+DEM 
    ```

3. Classes Extent in a discrete raster (PTA)

   Load protected_areas, LC 1995, LC 2015 (check resolution: 0.00277778)

   1.  PTA r.stats on a single raster
  
      `*  r.stats - input LandCover 1995, print area totals, suppress any NULL`
   
   2.  PTA r.stats on multiple rasters:
       
       *  convert (few) vectors to rasters:
    
         ```
          *  filter protected_areas (eg: "area_geo" >= 10000)
          *  PTA v.to.rast.attribute	(input protected_areas, iterate over this layer, att wdpaid, resolution 0.00277778)
         ```
    
       *  LC: PTA r.stats
       
          `*  r.stats - input rasterized PA+LC 1995, print area totals, suppress any NULL`
       
       *  LCC: PTA r.stats
       
          `*  r.stats - input rasterized PA+LC 1995+LC 2015, print area totals, suppress any NULL`

_____________________________________________________________________________________


## Beyond shapefiles and GeoTIFF

###  Using Postgis as a data store (PGAdmin, QGIS, BASH)

1. Create foss4g DB in PGAdmin
   *  Connect to localhost server
   *  Create new db foss4g, user=user
   *  Connect to brand new foss4g DB
   *  Create a new object/new extension/postgis in foss4g DB
2.  Connect to foss4g DB from QGIS
    *  Create a new PostGIS connection
       *  host=localhost
       *  database=foss4g
       *  username and pwd=user (save)
       *  only look in the public schema
       *  also list tables with no geometry
    *  refresh and connect from the elephant icon
3.  Import dataset into foss4g DB from QGIS

    Load country_dissolved, protected areas and species

    *  open database/db manager
    *  select PostGIS/foss4g/public from the tree
    *  import the loaded vectors (convert field names to lower case, create spatial index)
       *  country_dissolved
       *  protected_areas: pkey=wdpaid
       *  species: pkey=id_no
    *  remove the original shapefiles
    *  load the new objects from db_manager

Quit QGIS, Disconnect and Drop foss4g DB from PGAdmin!

4.  Do all the above with one command only

From LXTerminal

```
*  cd /media/user/usbdata/foss4g/scripts/
*  ./script_03_bulk_db_creation.sh
```

From file manager, open the above [script](scripts/script_03_bulk_db_creation.sh) with Geany, and have a look at it and at related SQL code:
*  [sl01_rename_geometry.sql](scripts/SQL/sl01_rename_geometry.sql)
*  [sl02_landcover.sql](scripts/SQL/sl02_landcover.sql)

It does:

*  create db foss4g and install spatialite extension
*  import all the vectors with ogr2ogr
*  import all the rasters with raster2pgsql
*  execute some sql code inside the db from the script
*  create new tables in the db and import the content from a csv file

### Using PostGIS as analysis engine

From PGAdmin Query Editor, open foss4g/scripts/SQL/

#### Spatial queries on intersecting vectors

[Exercise 1](/scripts/sql/ex01_vector_intersection.sql)

#### Zonal statistics on continuous raster

[Exercise 2](scripts/sql/ex02_raster_analysis_zonal_statistcs.sql)

#### On the fly classes extent on discrete raster

[Exercise 3](./scripts/sql/ex03_raster_extent.sql)

If something of the above goes wrong, the following script will create the needed functions for the next step (only needed if something didn't work during the previous exercises)				

From LXTerminal

```
*  cd /media/user/usbdata/foss4g/scripts/
*  ./script_04_create_functions.sh
```

#### Static classes extent on discrete raster

From LXTerminal

```
*  cd /media/user/usbdata/foss4g/scripts/
*  ./script_05_final.sh
```

From file manager, open the above script with Geany, and have a look at it and at related SQL code. It does:

*  performs the raster analyis looping through each protected area, for each epoch
  *  using function created in the previous steps
  *  parallelizing the calculation (efficiency depends on available cores)
*  formats the outputs
*  create a quicker function

While the above run, from a new LXTerminal

`*  htop`

You can see from here how all cores are used in parallel.

_____________________________________________________________________________________


## Publishing to the outside world

### Deploying functions as REST services

From LXTerminal

```
*  cd /media/user/usbdata/foss4g/scripts/rest/
*  python server.py &
```

From Firefox

```
*  visit http://localhost:8888/rest_doc.py
```

To stop the rest server, from LXTerminal

```
* ps
* take note of the "python" PID.
```

EG:

```
  PID TTY          TIME CMD
  5528 pts/0    00:00:00 bash
  10122 pts/0    00:00:00 python 
  10229 pts/0    00:00:00 ps
```

On the example above PID is 10122

`* kill the noted PID.`

EG:

`kill 10122`

## Proceed with the next session: [web development](/media/user/usbdata/foss4g/docs/docs2_web.html)

<p style='text-align: right;'> <b>Andrea Mandrici</b> </p> 

### MANY THANKS TO:

Lucy Bastin, Martino Boni, Giacomo Delli, Eduardo Garcia Bendito, Luca Marletta, Christian Zanardi
