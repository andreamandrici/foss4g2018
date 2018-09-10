---------------------------------------------------
-- 1 -- explore the multiband raster Landcover 1995_2015
---------------------------------------------------
WITH
lc_95_15 AS (
SELECT
rid,
rast
FROM lc_1995_2015
)
SELECT * FROM lc_95_15

---------------------------------------------------
-- 2 -- explore the attributes table for Landcover
---------------------------------------------------
SELECT
*
FROM lc_attributes

---------------------------------------------------
-- 3 -- summarizing statistics as in the previous exercise on the new raster source
-- 	... but landcover contains discrete values, and here this approach is not appropriate!
---------------------------------------------------
WITH
lc_95 AS ( -- <-- we select only epoch 1995 by selecting band 1
SELECT
b.wdpaid,
---------------------------------------------------
-- since this is multiband, we add 2 parameters: band 1 is year 1995, true to exclude nulls
---------------------------------------------------
ST_UNION(ST_CLIP(a.rast,1,b.geom,true)) AS rast
-- ST_UNION(ST_CLIP(a.rast,2,b.geom,true)) AS rast -- <-- changing the band number would give us results for year 2015 (band 2)
FROM lc_1995_2015 a, (
	SELECT
	wdpaid,
	geom
	FROM protected_areas
	WHERE wdpaid=916 -- <-- for prototyping we select one protected area only
) b
WHERE ST_INTERSECTS(b.geom,a.rast)
GROUP BY b.wdpaid
)
SELECT wdpaid,(stats).*
FROM (SELECT wdpaid,ST_SummaryStats(rast) AS stats FROM lc_95) AS results 

---------------------------------------------------
-- 4 -- we step back to the clip of the raster on the protected area boundary, then:
	-- vectorize on-the-fly the clipped categories (lc_95_vect )
	-- calculate extent of the vectorized polygons, attributing the right value (lc class)
	-- GROUP BY lc_class, and SUM the extents
---------------------------------------------------
WITH
lc_95 AS (
SELECT
b.wdpaid,
ST_UNION(ST_CLIP(a.rast,1,b.geom,true)) AS rast
FROM lc_1995_2015 a, (
	SELECT
	wdpaid,
	geom
	FROM protected_areas
	WHERE wdpaid=916
) b
WHERE ST_INTERSECTS(b.geom,a.rast)
GROUP BY b.wdpaid
),
---------------------------------------------------
-- next vectorize on the fly
---------------------------------------------------
lc_95_vect AS (
SELECT
wdpaid,
ST_DumpAsPolygons(rast) AS vr -- <-- this creates vector polygons out of clusters of pixels with the same value
FROM lc_95)
SELECT
wdpaid,
(vr).val as lc_code, -- <-- this one gets the pixel value=land cover code
SUM(ST_AREA((vr).geom::GEOGRAPHY)/1000000) AS area_geo -- <-- this calculates extension of the polygons in sqm using the best projection for the area; we transform result in sqkm
FROM lc_95_vect
GROUP BY wdpaid,lc_code
ORDER BY wdpaid,lc_code

---------------------------------------------------
-- 5 -- we can rewrite everything above as subqueries and join land cover classes descriptions
---------------------------------------------------
WITH
lc_95_final AS (
SELECT
wdpaid,
(vr).val::integer as lc_code,
SUM(ST_AREA((vr).geom::GEOGRAPHY)/1000000) AS area_geo
FROM (
	SELECT
	wdpaid,
	ST_DumpAsPolygons(rast) AS vr
	FROM (
		SELECT
		b.wdpaid,
		ST_UNION(ST_CLIP(a.rast,1,b.geom,true)) AS rast -- <-- remember that is always possible to change to band 2, and get 2015 results	
		FROM lc_1995_2015 a, (
			SELECT
			wdpaid,
			geom
			FROM protected_areas
			WHERE wdpaid=916
		) b
		WHERE ST_INTERSECTS(b.geom,a.rast)
		GROUP BY b.wdpaid
		) As lc_95
	) lc_95v
GROUP BY
wdpaid,
lc_code
ORDER BY
wdpaid,
lc_code)

SELECT
a.*,
b.lc_class
FROM lc_95_final a
JOIN lc_attributes b ON a.lc_code=b.lc_code

---------------------------------------------------
-- 6 -- we can also aggregate by higher level landcover classes
---------------------------------------------------
WITH
lc_95_final AS (
SELECT
wdpaid,
(vr).val::integer as lc_code,
SUM(ST_AREA((vr).geom::GEOGRAPHY)/1000000) AS area_geo
FROM (
	SELECT
	wdpaid,
	ST_DumpAsPolygons(rast) AS vr
	FROM (
		SELECT
		b.wdpaid,
		ST_UNION(ST_CLIP(a.rast,1,b.geom,true)) AS rast -- <-- remember that is always possible to change to band 2, and get 2015 results	
		FROM lc_1995_2015 a, (
			SELECT
			wdpaid,
			geom
			FROM protected_areas
			WHERE wdpaid=916
		) b
		WHERE ST_INTERSECTS(b.geom,a.rast)
		GROUP BY b.wdpaid
		) As lc_95
	) lc_95v
GROUP BY wdpaid,lc_code
ORDER BY wdpaid,lc_code)

SELECT
a.wdpaid,
SUM(a.area_geo) area_geo,
b.lc1_code, -- <-- note the different aggregation level
b.lc1_class -- <-- note the different aggregation level
FROM lc_95_final a
JOIN lc_attributes b ON a.lc_code=b.lc_code
---------------------------------------------------
-- we group by protected area and by the higher aggregation level (code and description)
---------------------------------------------------
GROUP BY wdpaid,lc1_code,lc1_class
ORDER BY wdpaid,lc1_code

---------------------------------------------------
-- 7 -- we can create a function to get the higher level landcover classes aggregation
---------------------------------------------------
DROP FUNCTION IF EXISTS get_pa_lc(integer,integer);
CREATE OR REPLACE FUNCTION public.get_pa_lc(
	IN wdpaid integer,
	IN band integer)
RETURNS TABLE(wdpaid integer,area_geo double precision,lc_code integer,lc_class text) AS
$BODY$ 

WITH
lc_final AS (
SELECT
wdpaid,
(vr).val::integer as lc_code,
SUM(ST_AREA((vr).geom::GEOGRAPHY)/1000000) AS area_geo
FROM (
	SELECT
	wdpaid,
	ST_DumpAsPolygons(rast) AS vr
	FROM (
		SELECT
		b.wdpaid,
		ST_UNION(ST_CLIP(a.rast,$2,b.geom,true)) AS rast -- <-- we pass here the band parameter (year)	
		FROM lc_1995_2015 a, (
			SELECT
			wdpaid,
			geom
			FROM protected_areas
			WHERE wdpaid=$1 -- <-- we pass here the protected area id
		) b
		WHERE ST_INTERSECTS(b.geom,a.rast)
		GROUP BY b.wdpaid
		) As lc
	) lc_vect
GROUP BY wdpaid,lc_code
ORDER BY wdpaid,lc_code)

SELECT
a.wdpaid,
SUM(a.area_geo) area_geo,
b.lc1_code lc_code, 
b.lc1_class lc_class
FROM lc_final a
JOIN lc_attributes b ON a.lc_code=b.lc_code
GROUP BY wdpaid,lc1_code,lc1_class
ORDER BY wdpaid,lc_code
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
  
---------------------------------------------------
-- 8 -- test the brand new function
---------------------------------------------------
SELECT * FROM get_pa_lc(916,1) -- <-- here we test year 1995 (band 1)

---------------------------------------------------
-- 9 -- calls the function multiple times and combine results
---------------------------------------------------
(SELECT
*,
'1995'::text AS "year" -- <-- we add a field with the year related to the band selected
FROM get_pa_lc(916,1)
)
UNION -- <-- we combine with the other band output
(SELECT
*,
'2015'::text AS "year"  -- <-- we add a field with the year related to the band selected
FROM get_pa_lc(916,2)
)
ORDER BY wdpaid,year,lc_code


