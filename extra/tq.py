#!/usr/bin/python3
import re
from datetime import datetime
import sys

def maptime(raw):
    t=raw.split(",")[0]
    dt_object = datetime.fromtimestamp(int(t)/1000)
    return str(dt_object)+" "+raw

f = open(sys.argv[1])
for l in f.readlines():
    nl=maptime(l)
    print(nl.strip())