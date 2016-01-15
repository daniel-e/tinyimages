#!/usr/bin/env python

from tinydb import TinyDB
import numpy as np

tdb = TinyDB()

z = np.zeros(tdb.dim(), np.int64)
for i in tdb.chunks():
	z += np.fromstring(i, np.uint8)
z = np.float64(z) / tdb.count()

print " ".join(["%f" % (i) for i in z.flatten()])
