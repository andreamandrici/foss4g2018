# Deploying functions as REST services

This is (a slightly modified) code developed by [Martino Boni](https://github.com/Martenz/local_cgi_rest).

From LXTerminal

```
* cd /media/user/usbdata/foss4g/scripts/
* ./script_06_rest.sh

*  cd /media/user/usbdata/foss4g/scripts/rest/
*  python server.py &
```

From Firefox

visit [http://localhost:8888/rest_doc.py](http://localhost:8888/rest_doc.py)

and follow the links.

To stop the rest server, from LXTerminal

```
* ps
* take note of the "python" PID.
```

EG:

```
  PID TTY          TIME CMD
  5528 pts/0    00:00:00 bash
  10122 pts/0    00:00:00 python 
  10229 pts/0    00:00:00 ps
```

On the example above PID is 10122

`* kill the noted PID.`

EG:

`kill 10122`.
