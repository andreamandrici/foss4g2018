---------------------------------------------
-- EXPLORE DATASETS
---------------------------------------------

---------------------------------------------
--- 1 - Protected Areas/SELECT the right FIELDS
---------------------------------------------
SELECT
* -- all fields
---------------------------------------------
-- SELECT individual fields uncommenting below (and commenting above!)
---------------------------------------------
-- wdpaid,
-- name,
-- marine,
-- geom
FROM protected_areas
LIMIT 10 -- <-- we limit the result this way
---------------------------------------------
--- order the result
---------------------------------------------
--ORDER BY wdpaid


---------------------------------------------
--- 2 - Species/SELECT the right FIELDS
---------------------------------------------
SELECT
* -- all fields
---------------------------------------------
-- SELECT individual fields uncommenting below (and commenting above!)
---------------------------------------------
-- id_no,
-- binomial,
-- code,
-- biome_marine,
-- biome_freshwater,
-- biome_terrestrial,
-- geom
FROM species

---------------------------------------------
-- 3 - SELECT INTERSECTING objects within the two datasets
---------------------------------------------
SELECT
a.wdpaid,
b.id_no,
a.geom, -- <-- not needed in the output
b.geom  -- <-- even if used in the intersection
FROM protected_areas a,species b
WHERE ST_INTERSECTS(a.geom,b.geom)
ORDER BY
a.wdpaid,
b.id_no

---------------------------------------------
-- 4 - SELECT all fields needed for INTERSECTING objects within the two datasets using subquery
---------------------------------------------
-- first create a subquery (WITH)
---------------------------------------------
WITH
pa_sp AS (
SELECT
a.wdpaid,
a.name,
a.marine,
b.id_no,
b.binomial,
b.biome_terrestrial,
b.biome_marine,
b.biome_freshwater,
b.code
FROM protected_areas a,species b
WHERE ST_INTERSECTS(a.geom,b.geom)
ORDER BY
a.wdpaid,
b.id_no)
---------------------------------------------
-- then select from the subquery
---------------------------------------------
SELECT * FROM pa_sp

---------------------------------------------
-- 5 - use CASE on the above to get more meaningful names in the FIELDS
---------------------------------------------
WITH pa_sp AS (
SELECT
a.wdpaid,
a.name,
CASE a.marine
  WHEN 0 THEN 'terrestrial'
  WHEN 1 THEN 'coastal'
  WHEN 2 THEN 'marine'
END AS type,
b.id_no,
b.binomial,
---------------------------------------------
-- we can concatenate more fields:
---------------------------------------------
(b.biome_terrestrial::text||b.biome_freshwater::text||b.biome_marine::text) AS biome,
---------------------------------------------
-- AND we can use CASE on the concatenated fields, on the fly:
--- comment the above, uncomment below
---------------------------------------------
--CASE (b.biome_terrestrial::text||b.biome_freshwater::text||b.biome_marine::text)::integer
--  WHEN 1 THEN 'marine'
--  WHEN 100 THEN 'terrestrial'
--END AS biome,
b.code
FROM protected_areas a,species b
WHERE ST_INTERSECTS(a.geom,b.geom)
ORDER BY
a.wdpaid,
b.id_no)
---------------------------------------------
-- select * from the subquery
---------------------------------------------
SELECT DISTINCT biome FROM pa_sp -- <-- this is here just to check how many biomes are present in our selection
--SELECT * FROM pa_sp -- <-- this is the real one
---------------------------------------------
-- test some selection criteria
---------------------------------------------
--WHERE type!=biome -- <-- this checks if the protected area habitat matches the species one
--WHERE wdpaid=916  -- <-- this selects only one protected area
--WHERE code='EN'   -- <-- this looks for endangered species






