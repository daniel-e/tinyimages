#!/usr/bin/env python

import random, sys

dst = sys.argv[1]

def random_row():
	return [random.randint(0, 255) for i in xrange(32 * 32 * 3)]

data = [random_row() for i in range(15000)]

f = open(dst + "/data.txt", "w")
for row in data:
	f.write(" ".join([str(i) for i in row]))
	f.write("\n")
f.close()

f = open(dst + "/data.bin", "w")
for row in data:
	f.write("".join([chr(i) for i in row]))
f.close()
