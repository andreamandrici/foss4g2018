---------------------------------------------
-- 1 -- SELECT one protected area with a subquery
---------------------------------------------
WITH
pa AS (
SELECT
wdpaid,
geom
FROM protected_areas
WHERE wdpaid=916
)
SELECT * FROM pa

---------------------------------------------
-- 2 -- explore the raster elevation model
---------------------------------------------
WITH
dem AS (
SELECT
rid,
-- ST_COUNT(rast), -- <-- this counts the pixels for each tile
rast
FROM dem
)
SELECT * FROM dem

---------------------------------------------
-- 3 -- put together the two subqueries above to SELECT dem TILES INTERSECTING the protected area
---------------------------------------------
WITH
pa AS (SELECT wdpaid,geom FROM protected_areas WHERE wdpaid=916),
dem AS (
SELECT
b.wdpaid,
a.rid,
a.rast
FROM dem a, pa b
WHERE ST_INTERSECTS(b.geom,a.rast)
)
SELECT * FROM dem

---------------------------------------------
-- 4 -- CLIP  the selected dem TILES on the boundary of the pa
---------------------------------------------
WITH
pa AS (
SELECT
wdpaid,
geom
FROM protected_areas
WHERE wdpaid=916
),
dem AS (
SELECT
b.wdpaid,
a.rid,
---------------------------------------------
-- also we count the number of pixels intersected and clipped
---------------------------------------------
ST_COUNT(a.rast) uclip_pixels, -- <-- this one counts pixels in tiles unclipped
ST_COUNT(ST_CLIP(a.rast,b.geom)) clip_pixels, -- <-- this one counts the pixels in the clipped tiles
---------------------------------------------
ST_CLIP(a.rast,b.geom) AS rast -- <-- this actually clips the raster to the shape of the protected area
FROM dem a, pa b
WHERE ST_INTERSECTS(b.geom,a.rast)
)
SELECT * FROM dem

---------------------------------------------
-- 5 -- next, we UNION the tiles GROUPING everything BY wdpaid
---------------------------------------------
WITH
pa AS (
SELECT
wdpaid,
geom
FROM protected_areas
WHERE wdpaid=916
),
dem AS (
SELECT
b.wdpaid,
ST_COUNT(ST_UNION(ST_CLIP(a.rast,b.geom))) clip_pixels, -- <-- this sums all the clipped pixels
ST_UNION(ST_CLIP(a.rast,b.geom)) AS rast -- <-- this union all the pixels
FROM dem a, pa b
WHERE ST_INTERSECTS(b.geom,a.rast)
GROUP BY b.wdpaid
)
SELECT * FROM dem

---------------------------------------------
-- 6 -- move the first WITH (pa) into a subquery of dem; we also remove the COUNT
---------------------------------------------
WITH
dem AS (
SELECT
b.wdpaid,
ST_UNION(ST_CLIP(a.rast,b.geom)) AS rast
FROM dem a, (
	SELECT
	wdpaid,
	geom
	FROM protected_areas
	WHERE wdpaid=916
) b
WHERE ST_INTERSECTS(b.geom,a.rast)
GROUP BY b.wdpaid
)
SELECT * FROM dem

---------------------------------------------
-- 7 -- calculate full STATISTICS for the above
---------------------------------------------
WITH
dem AS (
SELECT
b.wdpaid,
ST_UNION(ST_CLIP(a.rast,b.geom)) AS rast
FROM dem a, (
	SELECT
	wdpaid,
	geom
	FROM protected_areas
	WHERE wdpaid=916 -- <-- we can also calculate statistics for all protected areas removing the selection on Serengeti
) b
WHERE ST_INTERSECTS(b.geom,a.rast)
GROUP BY b.wdpaid
)
SELECT wdpaid,ST_SummaryStats(rast) AS stats FROM dem
---------------------------------------------
-- comment above, uncomment below, to get a better formatting
---------------------------------------------
--SELECT wdpaid,(stats).*
--FROM (SELECT wdpaid,ST_SummaryStats(rast) AS stats FROM dem) AS results ORDER BY wdpaid

---------------------------------------------
-- 8 -- create a function with the above select
---------------------------------------------
DROP FUNCTION IF EXISTS get_pa_dem_stats(integer);
CREATE OR REPLACE FUNCTION get_pa_dem_stats(IN wdpaid integer)
  RETURNS TABLE(
---------------------------------------------
-- describe the output structure
---------------------------------------------
  wdpaid integer, 
  count bigint, 
  sum double precision, 
  mean double precision, 
  stdev double precision, 
  min double precision, 
  max double precision
  ) 
  AS
---------------------------------------------
-- define the query to be run
---------------------------------------------  
$BODY$ 
WITH
dem AS (
SELECT
b.wdpaid,
ST_UNION(ST_CLIP(a.rast,b.geom)) AS rast
FROM dem a, (
	SELECT
	wdpaid,
	geom
	FROM protected_areas
	WHERE wdpaid=$1) b -- <-- use the first parameter
WHERE ST_INTERSECTS(b.geom,a.rast)
GROUP BY b.wdpaid
)
SELECT wdpaid,(stats).*
FROM (SELECT wdpaid,ST_SummaryStats(rast) AS stats FROM dem) AS results ORDER BY wdpaid
$BODY$
---------------------------------------------
-- this is the end of the query definition
---------------------------------------------
  LANGUAGE sql;

---------------------------------------------
-- 9 -- test the above function
---------------------------------------------
SELECT * FROM get_pa_dem_stats(916)



