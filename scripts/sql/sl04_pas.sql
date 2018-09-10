-------------------------------------------------------
-- compile a list of protected areas in each block
-------------------------------------------------------
SELECT wdpaid
FROM protected_areas
WHERE area_geo >= 100 -- <-- we reduce a bit the calculation selecting areas bigger than 100 sqkm only
ORDER BY wdpaid
OFFSET :vOFF LIMIT :vLIM -- <-- we pass here the offset/limit variables
;
