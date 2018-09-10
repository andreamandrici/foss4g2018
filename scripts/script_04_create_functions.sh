#!/bin/bash

# SET SOME VARIABLES
SQL="./sql"
dpath="/media/user/usbdata/foss4g/DATA"
dbpar="host=localhost user=user dbname=foss4g"


## EXECUTE EXTERNAL SQL CODE FROM BASH SCRIPT

### create some of the functions
psql -d foss4g -f ${SQL}/sl03_functions.sql;
