#!/usr/bin/env python2.7

import BaseHTTPServer
import CGIHTTPServer
import webbrowser

# Set PORT to provide rest
PORT = 8888

# Open by default your browser to the rest location without parameters
#webbrowser.open_new_tab('http://localhost:'+str(PORT)+'/rest_doc.py')

# Start HTTP server plus CGI Scripts Handler
server = BaseHTTPServer.HTTPServer

# Handle CGI Scripts
handler = CGIHTTPServer.CGIHTTPRequestHandler
handler.cgi_directories = ["/"]

server_address = ("",PORT)
httpd = server(server_address, handler)
httpd.serve_forever()

print "Serving at port: "+PORT