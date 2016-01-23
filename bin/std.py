#!/usr/bin/env python

from tinydb import TinyDB
import numpy as np

tdb = TinyDB(parse_args = False)
tdb.arg_parser().add_argument("-o", required = True)
tdb.arg_parser().add_argument("--mean", required = True)
args = tdb.parse_args()

# read the mean for each dimension
mean = np.array([float(i) for i in open(args.mean).readline().strip().split(" ")], np.float64)
assert(len(mean) == 3072)

z = np.zeros(tdb.dim(), np.float64)
for i in tdb.chunks():
	z += np.power(np.float64(np.fromstring(i, np.uint8)) - mean, 2)
z = np.sqrt(z / tdb.count())

open(args.o, "w").write(" ".join(["%f" % (i) for i in z.flatten()]))
