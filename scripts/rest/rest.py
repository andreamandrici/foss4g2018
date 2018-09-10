#!/usr/bin/env python

import cgi
import psycopg2
import json

DBNAME = 'foss4g'
HOST = 'localhost'
USER = 'user'
PASSWORD = 'user'


#---------- DB Tab&Fun QUERYs ----------#
def callDBtableview(schema,table):
    conn = psycopg2.connect(dbname=DBNAME, host=HOST, user=USER, password=PASSWORD)
    cur = conn.cursor()
    cur.execute('SELECT * FROM "'+schema+'"."'+table+'" ')
    colnames = [desc[0] for desc in cur.description]
    
    results = []
    for row in cur.fetchall():
        results.append(dict(zip(colnames, row)))

    return json.dumps(results, indent=2)

def callDBfunction(schema,fun,params):
    conn = psycopg2.connect(dbname=DBNAME, host=HOST, user=USER, password=PASSWORD)
    cur = conn.cursor()
    cur.execute('SELECT * FROM "'+schema+'"."'+fun+'"('+params+')')
    colnames = [desc[0] for desc in cur.description]
    
    results = []
    for row in cur.fetchall():
        results.append(dict(zip(colnames, [str(r) for r in row])))

    return json.dumps(results, indent=2)

form = cgi.FieldStorage()

val1 = form.getvalue('first')

#---------- Generate JSON Response ----------#
print "Content-type: application/json"
print "Status: 200 OK"
print "Content-Type: application/json"
print "Access-Control-Allow-Origin: *"

body = json.dumps({'name':'Duccio'})

body = json.dumps({})
arguments = cgi.FieldStorage()
if arguments.has_key('type'):
    if arguments['type'].value == 'tab':
        body = callDBtableview(arguments['schema'].value,arguments['obj'].value)
    elif arguments['type'].value == 'fun':
        params = ""
        if arguments.has_key('params'):
            params += arguments['params'].value[1:-1].replace(":",":=")
        body = callDBfunction(arguments['schema'].value,arguments['obj'].value, params)
    else:
        body = json.dumps( { 'Error' : 'Wrong type parameters, must be: type=tab or type=fun'} )

else:
    body = json.dumps( {'Error' : 'Wrong parameters, must be ?type=[tab/fun]&schema=[schema_name]&obj=[table_name/function_name]&params=(p1:1,p2:2,...,pn=n)'} )
   

print "Content-Length: %d" % (len(body))
print ""
print body

#print """Content-type: text/html
#
#<html><head><title>Test URL Encoding</title></head><body>
#Hello my name is %s
#</body></html>""" % (val1)
