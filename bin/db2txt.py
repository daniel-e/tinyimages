#!/usr/bin/env python

from tinydb import TinyDB

tdb = TinyDB()
for data in tdb.chunks():
	print " ".join([str(ord(i)) for i in data])
