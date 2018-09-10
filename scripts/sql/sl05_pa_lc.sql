-------------------------------------------------------
-- do the analyis
-------------------------------------------------------
INSERT INTO temp_pa_lc_1995_2015 -- <-- write in a new temporary table
(
SELECT
wdpaid,
'1995'::text AS "year",
lc_code,
area_geo
FROM get_pa_lc(:vPA,1) -- <--- select first band (year)
)
UNION
(
SELECT
wdpaid,
'2015'::text AS "year",
lc_code,
area_geo
FROM get_pa_lc(:vPA,2)  -- <--- select second band (year)
)
ORDER BY wdpaid,"year",lc_code

