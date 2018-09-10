DROP FUNCTION IF EXISTS get_pa_lc_1995_2015(integer);
CREATE OR REPLACE FUNCTION get_pa_lc_1995_2015(IN wdpaid integer)
  RETURNS TABLE(wdpaid integer, name text, _1995_nat numeric, _2015_nat numeric, _1995_man numeric, _2015_man numeric, _1995_cul numeric, _2015_cul numeric, _1995_wat numeric, _2015_wat numeric) AS
$BODY$ 
 SELECT 
 wdpaid,
 name,
 "1995_nat",
 "2015_nat",
 "1995_man",
 "2015_man",
 "1995_cul",
 "2015_cul",
 "1995_wat",
 "2015_wat"
 from pa_lc_1995_2015 WHERE wdpaid=$1 
$BODY$
  LANGUAGE sql;
