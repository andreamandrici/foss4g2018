-------------------------------------------------------
-- create final table with land cover for both years for all PAs >= 100 sqkm
-------------------------------------------------------
DROP TABLE IF EXISTS pa_lc_1995_2015;

-------------------------------------------------------
-- create with a cross join a list of all PAs with all 4 LC classes
-------------------------------------------------------
CREATE TABLE pa_lc_1995_2015 AS

WITH
pa_lc_code AS (
SELECT DISTINCT
a.wdpaid,
a.name,
b.lc1_code lc_code,
b.lc1_class lc_class
FROM protected_areas a, lc_attributes b
WHERE b.lc1_code IS NOT NULL
AND a.area_geo >= 100
ORDER BY
a.wdpaid,
b.lc1_code),

-------------------------------------------------------
-- join the above list with temporary analysis table
-------------------------------------------------------
lc_epochs AS (
SELECT
a.wdpaid,
a.lc_code,
a.lc_class,
b.area_geo ag95,
c.area_geo ag15
FROM pa_lc_code a
LEFT JOIN (SELECT * FROM temp_pa_lc_1995_2015 WHERE "year"='1995') b ON a.wdpaid=b.wdpaid AND a.lc_code=b.lc_code
LEFT JOIN (SELECT * FROM temp_pa_lc_1995_2015 WHERE "year"='2015') c ON a.wdpaid=c.wdpaid AND a.lc_code=c.lc_code
ORDER BY
a.wdpaid,
a.lc_code),

-------------------------------------------------------
-- reformat the output
-------------------------------------------------------
final_result AS (
SELECT DISTINCT
a.wdpaid,
j.name,
ROUND(COALESCE(b.ag95,0)::numeric,2) "1995_nat",
ROUND(COALESCE(c.ag95,0)::numeric,2) "1995_man",
ROUND(COALESCE(d.ag95,0)::numeric,2) "1995_cul",
ROUND(COALESCE(e.ag95,0)::numeric,2) "1995_wat",
ROUND(COALESCE(f.ag15,0)::numeric,2) "2015_nat",
ROUND(COALESCE(g.ag15,0)::numeric,2) "2015_man",
ROUND(COALESCE(h.ag15,0)::numeric,2) "2015_cul",
ROUND(COALESCE(i.ag15,0)::numeric,2) "2015_wat"
FROM lc_epochs a
LEFT JOIN (SELECT wdpaid,ag95 FROM lc_epochs WHERE lc_code=1) b ON a.wdpaid=b.wdpaid
LEFT JOIN (SELECT wdpaid,ag95 FROM lc_epochs WHERE lc_code=2) c ON a.wdpaid=c.wdpaid
LEFT JOIN (SELECT wdpaid,ag95 FROM lc_epochs WHERE lc_code=3) d ON a.wdpaid=d.wdpaid
LEFT JOIN (SELECT wdpaid,ag95 FROM lc_epochs WHERE lc_code=4) e ON a.wdpaid=e.wdpaid
LEFT JOIN (SELECT wdpaid,ag15 FROM lc_epochs WHERE lc_code=1) f ON a.wdpaid=f.wdpaid
LEFT JOIN (SELECT wdpaid,ag15 FROM lc_epochs WHERE lc_code=2) g ON a.wdpaid=g.wdpaid
LEFT JOIN (SELECT wdpaid,ag15 FROM lc_epochs WHERE lc_code=3) h ON a.wdpaid=h.wdpaid
LEFT JOIN (SELECT wdpaid,ag15 FROM lc_epochs WHERE lc_code=4) i ON a.wdpaid=i.wdpaid
JOIN pa_lc_code j ON a.wdpaid=j.wdpaid
ORDER BY a.wdpaid
)

SELECT * FROM final_result;
-------------------------------------------------------
-- add primary key
-------------------------------------------------------
ALTER TABLE pa_lc_1995_2015 ADD PRIMARY KEY (wdpaid);

-------------------------------------------------------
-- drop the pk from pa table: needed by geoserver in the next step
-------------------------------------------------------
ALTER TABLE protected_areas DROP CONSTRAINT protected_areas_pkey;

-------------------------------------------------------
-- drop the temporary analysis table
-------------------------------------------------------
-- DROP TABLE temp_pa_lc_1995_2015; -- <-- well... we keep it for a while...
