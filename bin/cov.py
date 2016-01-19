#!/usr/bin/env python

import sys
import numpy as np
import scipy.io as sio

from tinydb import TinyDB
from parallel import process

WIDTH = 32
HEIGHT = 32
CHANNELS = 3
DIM = WIDTH * HEIGHT * CHANNELS

tdb = TinyDB(dimensions = DIM, parse_args = None)
tdb.arg_parser().add_argument("--mean", required = True)
tdb.arg_parser().add_argument("--rows", type = int, default = 20000)
tdb.arg_parser().add_argument("-o", required = True)
args = tdb.parse_args()

# read the mean for each dimension
mean = np.array([float(i) for i in open(args.mean).readline().strip().split(" ")], np.float64)
assert(len(mean) == DIM)


def compute(m):
	k = np.matrix([np.fromstring(i, np.uint8) for i in m]) - mean
	return k.transpose() * k

jobs = process(tdb.groups(args.rows), compute)
m = reduce(lambda acc, x: acc + x, jobs, np.zeros((DIM, DIM), np.float64))

print >> sys.stderr, "processed rows:", tdb.count()

sio.savemat(args.o, {"c": m, "n": tdb.count()}, do_compression = True)
