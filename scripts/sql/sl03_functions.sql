---------------------------------------------
-- 1 -- create get_pa_dem_stats(integer) function
---------------------------------------------
DROP FUNCTION IF EXISTS get_pa_dem_stats(integer);
CREATE OR REPLACE FUNCTION get_pa_dem_stats(IN wdpaid integer)
  RETURNS TABLE(
  wdpaid integer, 
  count bigint, 
  sum double precision, 
  mean double precision, 
  stdev double precision, 
  min double precision, 
  max double precision
  ) 
  AS
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
	WHERE wdpaid=$1) b
WHERE ST_INTERSECTS(b.geom,a.rast)
GROUP BY b.wdpaid
)
SELECT wdpaid,(stats).*
FROM (SELECT wdpaid,ST_SummaryStats(rast) AS stats FROM dem) AS results ORDER BY wdpaid
$BODY$
LANGUAGE sql;

---------------------------------------------------
-- 2 -- create get_pa_lc(integer,integer) function
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
		ST_UNION(ST_CLIP(a.rast,$2,b.geom,true)) AS rast
		FROM lc_1995_2015 a, (
			SELECT
			wdpaid,
			geom
			FROM protected_areas
			WHERE wdpaid=$1
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
  LANGUAGE sql;
