Please copy here all downloaded and renamed datasets.
At the end of the process this folder must contain (names are compulsory):

*  cutters/
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
*  wdpa.zip

Above files must be downloaded from (the following links may require registration):

1.  [GADM](https://gadm.org/) (please note: we currently use [FAO GAUL data](http://www.fao.org/geonetwork/srv/en/metadata.show?id=12691), but GADM is open):
    *  [Tanzania Admin Areas](https://biogeo.ucdavis.edu/data/gadm3.6/shp/gadm36_TZA_shp.zip)
2.  [Marine Regions EEZ](http://www.marineregions.org/):
    *  [Tanzania EEZ](http://geo.vliz.be/geoserver/wfs?request=getfeature&service=wfs&version=1.0.0&typename=MarineRegions:eez&outputformat=SHAPE-ZIP&filter=%3CPropertyIsEqualTo%3E%3CPropertyName%3Emrgid%3C%2FPropertyName%3E%3CLiteral%3E8479%3C%2FLiteral%3E%3C%2FPropertyIsEqualTo%3E)
3.  [UNEP-WCMC WDPA](https://www.protectedplanet.net):
	  *  [current TZ WDPA](https://www.protectedplanet.net/country/TZ), click on "Download this dataset" on the top-right, and choose ".SHP" format.
	
	  Extract **all** the WDPA\__MonthYear_\_TZA-shapefile-**polygons**.* files from the downloaded zip, rename **each of them** as wdpa.\*, then compress them back in a **wdpa.zip** archive. You can delete the original zip archive and the extracted files.
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
