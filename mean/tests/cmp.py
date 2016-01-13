#!/usr/bin/env python

import math

x = [float(i) for i in open("out_mean_py.txt").readline().strip().split(" ")]
y = [float(i) for i in open("out_mean_octave.txt").readline().strip().split(" ")]

assert(len(x) == len(y))
assert(len(x) == 32 * 32 * 3)

for a, b in zip(x, y):
	assert(math.fabs(a - b) < 0.0000001)

print "ok"
