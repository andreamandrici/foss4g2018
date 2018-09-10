#!/usr/bin/env python

print """Content-type: text/html

<html><head><title>Local Rest Services</title></head><body>

<h1>Local Rest Services</h1>
<hr></hr>
<h2>Doc</h2>
<dl>
   <dt><b>Edit Server PORT (default: 8888)</b></dt>
       <dl>Edit server.py change PORT  variable (line </dl>
   <dt><b>Edit Database Connection</b></dt>
       <dl>Edit rest.py
               <p>DBNAME = 'foss4g'</p> 
<p>HOST = 'localhost'</p> 
<p>USER = 'user'</p> 
<p>PASSWORD = 'user!'</p> 
       </dl>
</dl>
<hr></hr>

<pre>Call existing services:
<h1>
	<a href='http://localhost:8888/rest.py?type=fun&schema=public&obj=get_pa_dem_stats&params=(wdpaid:916)' target='_blank'>get_pa_dem_stats(wdpaid)</a>
	<a href='http://localhost:8888/rest.py?type=fun&schema=public&obj=get_pa_lc&params=(wdpaid:916,band:1)' target='_blank'>get_pa_lc(wdpaid,band)</a>	
	<a href='http://localhost:8888/rest.py?type=fun&schema=public&obj=get_pa_lc_1995_2015&params=(wdpaid:916)' target='_blank'>get_pa_lc_1995_2015(wdpaid)</a>
</h1>
</pre>

eg:

"href='http://localhost:8888/rest.py?type=fun&schema=public&obj=get_pa_dem_stats&amp;params=(wdpaid:916)"

<p>where </p> 
<p><b>type=</b> can be 'tab' (for tables and views calls) or 'fun' (to call functions)</p> 
<p><b>schema=</b> Database schema name</p> 
<p><b>obj=</b> Table or View or Function name</p> 
<p><b>params=</b> series of parameters, used only with <b>type=fun</b>  </p>
<dt> eg. params=(param1:value1, param2:value2)</dt> 
<p>Note: when calling tables or views leave <b>params=</b></p>


</body></html>"""
