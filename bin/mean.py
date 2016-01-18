#!/usr/bin/env python

from tinydb import TinyDB
import numpy as np

tdb = TinyDB(parse_args = False)
tdb.arg_parser().add_argument("-o", required = True)
args = tdb.parse_args()

z = np.zeros(tdb.dim(), np.int64)
for i in tdb.chunks():
	z += np.fromstring(i, np.uint8)
z = np.float64(z) / tdb.count()

open(args.o, "w").write(" ".join(["%f" % (i) for i in z.flatten()]))
