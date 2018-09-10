#!/bin/bash

# SET SOME VARIABLES
SQL="./sql"
dpath="/media/user/usbdata/foss4g/DATA"
dbpar="host=localhost user=user dbname=foss4g"

## EXECUTE EXTERNAL SQL CODE FROM BASH SCRIPT

### 1 -- drop temporary analysis table, if exists
psql -t -d foss4g -c "DROP TABLE IF EXISTS temp_pa_lc_1995_2015;" 

### 2 -- create empty temporary analysis table
psql -t -d foss4g -c \
"CREATE TABLE temp_pa_lc_1995_2015 (
  wdpaid integer,
  year text,
  lc_code integer,
  area_geo double precision
);" 

wait

### 3 -- set LIMIT-OFFSET variables for a LOOP through each protected areas over 100 sqkm (202),
###   -- in blocks of 10, with a limit of 203
LIM=10 

for ((OFF=0 ; OFF<=203; OFF+=10))
  do
### 4 -- compile a list of protected areas in each block
    PAS=`psql -t -d foss4g -v vOFF=${OFF} -v vLIM=${LIM} -f ${SQL}/sl04_pas.sql`  
    
### 5 -- for each PA in each block of the LOOP...
	for PA in $PAS
        do
	    echo "PA processed "$PA
	    ### ... do the analyis
        pa_lc=`psql -t -d foss4g -v vPA=${PA} -f ${SQL}/sl05_pa_lc.sql`      
    done &
done

wait 

echo "analysis done!"

## 6 -- create final pa_lc_1995_2015 table (and drop the temporary analysis table)

psql -t -d foss4g -f ${SQL}/sl06_pa_lc_1995_2015.sql

echo "table pa_lc_1995_2015 created"

## 7 -- create get_pa_lc_1995_2015(integer) function

psql -t -d foss4g -f ${SQL}/sl07_get_pa_lc_1995_2015.sql

echo "function get_pa_lc_1995_2015 created"
