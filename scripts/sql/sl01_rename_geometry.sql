ALTER TABLE public.country_dissolved RENAME wkb_geometry  TO geom;
ALTER TABLE public.country_land RENAME wkb_geometry  TO geom;
ALTER TABLE public.country_marine RENAME wkb_geometry  TO geom;
ALTER TABLE public.protected_areas RENAME wkb_geometry  TO geom;
ALTER TABLE public.species RENAME wkb_geometry  TO geom;
ALTER TABLE public.species RENAME biome_mari TO biome_marine;
ALTER TABLE public.species RENAME biome_fres TO biome_freshwater;
ALTER TABLE public.species RENAME biome_terr TO biome_terrestrial;
