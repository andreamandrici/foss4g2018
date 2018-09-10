LOCAL CGI Script for Rest Services: Postgres to JSON

    Basic Ubuntu 14.04.5 LTS Workspace (Blank)
    PostgreSQL 9.3.18
    Python 2.7.6

Please check that *.py files are executable and check if you already have python 2.7x + psycopg2 module installed.

------------------
How To Setup and Run
------------------

Set file permnissions

    sudo chmod a+x rest.py
    sudo chmod a+x server.py
    sudo chmod a+x rest_doc.py
    
    
Set DB connection in rest.py

    07#  DBNAME = 'foss4g'
    08#  HOST = 'localhost'
    09#  USER = 'user'
    10#  PASSWORD = 'user'


Go to the folder and start the CGI Script for Local Rest Service Server (set PORT in server.py)

    python server.py


Create a function in the postgres DB using PGAdmin

    
    -- DROP FUNCTION public.get_pa_lc_1995_2015(integer);

    CREATE OR REPLACE FUNCTION public.get_pa_lc_1995_2015(IN wdpaid integer)
      RETURNS TABLE(
      wdpaid integer, 
      name text, 
      _1995_nat double precision, 
      _2015_nat double precision, 
      _1995_man double precision, 
      _2015_man double precision, 
      _1995_cul double precision, 
      _2015_cul double precision, 
      _1995_wat double precision, 
      _2015_wat double precision
      ) 
      AS
      
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
     from public.pa_lc_1995_2015 WHERE wdpaid=$1 
    $BODY$
      LANGUAGE sql VOLATILE
      COST 100
      ROWS 1000;
    ALTER FUNCTION public.get_pa_lc_1995_2015(integer)
      OWNER TO "user";


Test the JSON response:
    
    eg call a function that list the protected area with id = 916
        
        curl "http://localhost:8888/rest.py?type=fun&schema=public&obj=get_pa_lc_1995_2015&params=(wdpaid:917)"
    
        that will print
        
        wdpaid	"917"
        name	"Ruaha National Park"
        _1995_wat	"0.00"
        _2015_man	"171.82"
        _1995_nat	"13626.90"
        _1995_man	"619.73"
        _1995_cul	"261.55"
        _2015_nat	"14075.46"
        _2015_cul	"260.89"
        _2015_wat	"0.00"
    


Go back to the [Application tutorial](https://github.com/lucageo/foss4g#download-the-application-repository) and download the reopository



url - parameters:
    
    - type = tab (or) fun  //tab to call tables or views, fun to call functions
    
    - schema = schema_name // eg.public default postgres schema
    
    - obj = table_name (or) view_name (or) function_name
    
    - params = (param1:'val1', param2:'val2', ... paramN:'valN')  //Optional definition of function parameters
      note: parameters values are not quoted so you have to use single quote in the call right now; will add the quoting
            directly in the function calling postgres functions.
